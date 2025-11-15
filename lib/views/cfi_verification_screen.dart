import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/client_controller.dart';
import '../controllers/fi_verification_service.dart';
import '../models/FiVerificationList_model.dart';
import '../models/client_model.dart';
import '../utils/app_constant.dart';

class CfiVerificationScreen extends StatefulWidget {
  const CfiVerificationScreen({super.key});

  @override
  State<CfiVerificationScreen> createState() => _CfiVerificationScreenState();
}

class _CfiVerificationScreenState extends State<CfiVerificationScreen> {
  final ClientService _clientService = ClientService();
  final FiVerificationService _fiService = FiVerificationService();

  List<ClientModel> _clients = [];
  ClientModel? _selectedClient;
  List<FiClientItem> _clientList = [];

  bool _loading = true;
  bool _isFetching = false;
  bool _hasFetchedData = false; // ✅ New Flag for "No data found" logic

  final TextEditingController _pickupfromdateController =
  TextEditingController();
  final TextEditingController _pickuptodateController = TextEditingController();

  String? _selectedStatus;

  // Status options match the API's expected 'feaction' values
  final List<String> _statusList = ['verified', 'not_veri', 'all'];
  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open browser");
    }
  }
  int? userId;
  @override
  void initState() {
    super.initState();
    _fetchClients();
    loadUserData();
  }
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  // --- Data Fetching Logic ---

  Future<void> _fetchClients() async {
    try {
      // Assuming '1' is the fixed branch ID for fetching the list of clients
      final clients = await _clientService.fetchClients(1);
      setState(() {
        _clients = clients;
        _loading = false;
        // Optionally pre-select the first client
        _selectedClient = clients.isNotEmpty ? clients.first : null;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching clients: $e')),
      );
    }
  }

  Future<void> _fetchVerificationData() async {
    if (_selectedClient == null ||
        _pickupfromdateController.text.isEmpty ||
        _pickuptodateController.text.isEmpty ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isFetching = true;
      _clientList = []; // Clear previous data
      _hasFetchedData = false; // Reset before fetching
    });

    try {
      final data = await _fiService.fetchVerificationClients(
        // ✅ Correction 1: Ensure clientId is passed as a String
        clientId: _selectedClient!.clientId.toString(),
        fromDate: _pickupfromdateController.text,
        toDate: _pickuptodateController.text,
        feaction: _selectedStatus!,
        typeId: "1", // Assuming '1' is a fixed Type ID
        branchId: "1", // Assuming '1' is a fixed Branch ID
      );
      print("-------------------------");
      print("-------------------------");
      print(data);
      print("-------------------------");
      print("-------------------------");

      setState(() {
        _clientList = data!;
        _isFetching = false;
        _hasFetchedData = true; // ✅ Data fetching finished
      });
    } catch (e) {
      setState(() {
        _isFetching = false;
        _hasFetchedData = true; // ✅ Fetch finished, but with error/empty result
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pickupfromdateController.dispose();
    _pickuptodateController.dispose();
    super.dispose();
  }

  // --- UI Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CFI Verification",
          style: TextStyle(color: AppConstant.appBarWhiteColor),
        ),
        backgroundColor: AppConstant.appBarColor,
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Client Dropdown
              DropdownButtonFormField<ClientModel>(
                value: _selectedClient,
                isExpanded: true,
                items: _clients.map((client) {
                  return DropdownMenuItem(
                    value: client,
                    child: Text(
                      client.clientName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedClient = value),
                decoration: const InputDecoration(
                  labelText: 'Choose Client',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // From Date
              TextFormField(
                controller: _pickupfromdateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Pickup Date From',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2005),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _pickupfromdateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // To Date
              TextFormField(
                controller: _pickuptodateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Pickup Date To',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2005),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _pickuptodateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: _statusList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedStatus = value),
                decoration: const InputDecoration(
                  labelText: 'Select Verification Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Fetch Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  onPressed: _isFetching ? null : _fetchVerificationData,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isFetching
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Fetch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Data Table / No Data Found Message
              if (_clientList.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey),
                    headingRowColor:
                    WidgetStateProperty.all(Colors.blue.shade100),
                    columns: const [
                      DataColumn(label: Text('View')),
                      DataColumn(label: Text('Branch')),
                      DataColumn(label: Text('Lead ID')),
                      DataColumn(label: Text('Mobile')),
                      DataColumn(label: Text('Customer Name')),
                      DataColumn(label: Text('Lead Status')),
                    ],
                    rows: _clientList.map((item) {
                      return DataRow(cells: [
                        DataCell(InkWell(
                            onTap:(){
                              //https://fms.bizipac.com/apinew/iserveu_fi/tu_report_verification.php?lead_id=4945000&teleid=7512
                              final url =
                                  "https://fms.bizipac.com/apinew/iserveu_fi/tu_report_verification.php?lead_id=${item.leadId ?? '-'}&teleid=$userId";
                              _launchInBrowser(url);
                            },
                            child: Text("Click",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),))),
                        DataCell(Text(item.branch_name ?? '-')),
                        DataCell(Text(item.leadId ?? '-')),
                        DataCell(Text(item.mobile ?? '-')),
                        DataCell(Text(item.customerName ?? '-')),
                        DataCell(Text(item.status_name ?? '-')),

                      ]);
                    }).toList(),
                  ),
                )
              // ✅ Correction 2: Show message only if fetching is complete AND list is empty
              else if (!_isFetching && _hasFetchedData)
                const Center(
                  child: Text(
                    "No data found for the selected criteria.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}