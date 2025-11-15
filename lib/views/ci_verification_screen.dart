import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/client_controller.dart';
import '../controllers/image_verification_controllers.dart';
import '../models/client_model.dart';
import '../models/image_verification_model.dart';
import '../utils/app_constant.dart';

class CiVerificationScreen extends StatefulWidget {
  const CiVerificationScreen({super.key});

  @override
  State<CiVerificationScreen> createState() => _CiVerificationScreenState();
}

class _CiVerificationScreenState extends State<CiVerificationScreen> {
  final ClientService _clientService = ClientService();
  List<ClientModel> _clients = [];
  ClientModel? _selectedClient;
  bool _loading = true;
  final TextEditingController _pickupfromdateController = TextEditingController();
  final TextEditingController _pickuptodateController = TextEditingController();
  String? _selectedStatus; // holds the selected item
  final List<String> _statusList = [
    'verified',
    'not_veri',
    'all',
  ];
  @override
  void initState() {
    super.initState();
    _fetchClients();
  }
  Future<void> _fetchClients() async {
    try {
      final clients = await _clientService.fetchClients(1); // branch = 1
      setState(() {
        _clients = clients;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("------------");
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching clients: $e')),
      );
    }
  }
  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open browser");
    }
  }
  ImageVerificationService service = ImageVerificationService();
  Imageverification? imageData;
  bool isLoading = true;
  void fetchData() async {
    if (_selectedClient == null ||
        _pickupfromdateController.text.isEmpty ||
        _pickuptodateController.text.isEmpty ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // ✅ Start loading
    setState(() {
      isLoading = true;
      imageData = null; // clear old data
    });

    imageData = await service.fetchImageVerification(
      clientId: _selectedClient!.clientId.toString(),
      fromDate: _pickupfromdateController.text,
      toDate: _pickuptodateController.text,
      feaction: _selectedStatus!,
    );

    // ✅ Stop loading
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("C I Verification",style: TextStyle(color: AppConstant.appBarWhiteColor),),
          backgroundColor: AppConstant.appBarColor,
          iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // 👈 instead of start
              children: [
                DropdownButtonFormField<ClientModel>(
                  value: _selectedClient,
                  isExpanded: true, // 👈 this fixes most overflow issues!
                  items: _clients.map((client) {
                    return DropdownMenuItem(
                      value: client,
                      child: Text(
                        client.clientName,
                        overflow: TextOverflow.ellipsis, // 👈 safely trims long text
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedClient = value),
                  decoration: const InputDecoration(
                    labelText: 'Choose Client',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pickupfromdateController,
                  readOnly: true, // 👈 prevents keyboard from opening
                  decoration: const InputDecoration(
                    labelText: 'Pickup Date From',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    // 👇 Open date picker
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (pickedDate != null) {
                      // 👇 Format to yyyy-MM-dd
                      String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        _pickupfromdateController.text = formattedDate;
                        print("-------------------------");
                        print(_pickupfromdateController);
                        print("-------------------------");
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pickuptodateController,
                  readOnly: true, // 👈 prevents keyboard from opening
                  decoration: const InputDecoration(
                    labelText: 'Pickup Date To',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    // 👇 Open date picker
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (pickedDate != null) {
                      // 👇 Format to yyyy-MM-dd
                      String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);

                      setState(() {
                        _pickuptodateController.text = formattedDate;
                        print("-------------------------");
                        print(_pickuptodateController);
                        print("-------------------------");
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true, // 👈 prevents overflow
                  items: _statusList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      print("-------------------------");
                      print(_selectedStatus);
                      print("-------------------------");
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Verification Status',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero, // 👈 Needed for gradient container
                      backgroundColor: Colors.transparent, // 👈 So gradient shows
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    onPressed: ()  {
                      fetchData();
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1976D2), // Deep blue
                            Color(0xFF42A5F5), // Light blue
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
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
                // ----------------------  AFTER FETCH BUTTON  -------------------------
                const SizedBox(height: 20),
// Show loader during fetch
// Show DataTable when data is available
                if (!isLoading && imageData != null && imageData!.client != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(color: Colors.grey),
                      headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                      columns: const [
                        DataColumn(label: Text('View')),
                        DataColumn(label: Text('Branch')),
                        DataColumn(label: Text('Lead ID')),
                        DataColumn(label: Text('Mobile')),
                        DataColumn(label: Text('Customer Name')),
                        DataColumn(label: Text('Verify By')),
                      ],
                      rows: imageData!.client!.map((item) {
                        return DataRow(cells: [
                          DataCell(
                            InkWell(
                              onTap: () {
                                final url = "https://fms.bizipac.com/secureapi/civ.php?lead_id=${item.leadId}&user_id=${item.verifyBy}";
                                _launchInBrowser(url);
                              },
                              child: const Text(
                                "Click",
                                style: TextStyle(
                                    color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataCell(Text(item.branchName ?? '-')),
                          DataCell(Text(item.leadId ?? '-')),
                          DataCell(Text(item.mobile ?? '-')),
                          DataCell(Text(item.customerName ?? '-')),
                          DataCell(Text(item.verifyBy ?? '-')),
                        ]);
                      }).toList(),
                    ),
                  ),
                if (!isLoading && (imageData == null || imageData!.client == null || imageData!.client!.isEmpty))
                  const Center(
                    child: Text(
                      "No data found for the selected criteria.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        )
    );
  }
}
