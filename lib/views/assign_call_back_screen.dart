import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/assign_to_tele_controller.dart';
import '../controllers/call_back_controller.dart';
import '../controllers/user_tele_controller.dart';
import '../models/call_back_model.dart';
import '../models/user_tele_response_model.dart';
import '../utils/app_constant.dart';

class AssignCallBackScreen extends StatefulWidget {
  final String branchid;
  final String user_id;
  const AssignCallBackScreen({super.key, required this.branchid,required this.user_id});

  @override
  State<AssignCallBackScreen> createState() => _AssignCallBackScreenState();
}

class _AssignCallBackScreenState extends State<AssignCallBackScreen> {
  Future<CallLaterResponse>? callLaterFuture;

  final TextEditingController _dateController = TextEditingController();
  final Set<String> selectedLeadIds = {};

  String selectedDate = "";

  /// Pagination
  static const int pageSize = 6;
  int currentPage = 0;
  List<CallLaterLead> _allLeads = [];

  /// Telecaller
  bool _isLoading = true;
  List<UserTeleModel> _userList = [];
  UserTeleModel? _selectedUser;
  final UserListController _controllerTele = UserListController();
  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(
        dateString,
      ); // API से जो format आता है वो parse होगा
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateString; // अगर parse fail हो जाए तो original string return
    }
  }
  /// 📅 Date Picker
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    final formattedDate =
        "${pickedDate.day.toString().padLeft(2, '0')}"
        ".${pickedDate.month.toString().padLeft(2, '0')}"
        ".${pickedDate.year}";

    setState(() {
      selectedDate = formattedDate;
      _dateController.text = formattedDate;
    });
  }

  /// 🔍 Search
  void _loadCallLaterLeads() {
    if (selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date")),
      );
      return;
    }

    setState(() {
      selectedLeadIds.clear();
      currentPage = 0;
      callLaterFuture = CallLaterService().fetchCallLaterLeads(
        dfrom: selectedDate,
        branch: widget.branchid,
        client: "0",
      );
    });
  }

  /// 👤 Load Telecaller
  Future<void> loadUsers() async {
    try {
      final result = await _controllerTele.fetchUsers(widget.branchid, "4");
      _userList = result
          .where((u) => u.branchMulti.split(",").contains(widget.branchid))
          .toList();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Pagination helpers
  List<CallLaterLead> get paginatedLeads {
    final start = currentPage * pageSize;
    final end = (start + pageSize).clamp(0, _allLeads.length);
    return _allLeads.sublist(start, end);
  }

  int get totalPages =>
      (_allLeads.length / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text(
          "Assign Call Back",
          style: TextStyle(color: AppConstant.appBarWhiteColor),
        ),
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: Column(
        children: [
          _buildFilterRow(),

          if (selectedLeadIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                "Selected Leads: ${selectedLeadIds.length}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(child: _buildResult()),

          if (_allLeads.isNotEmpty) _buildPagination(),

          if (selectedLeadIds.isNotEmpty) _buildAssignSection(),
        ],
      ),
    );
  }

  /// 🔹 Filter UI
  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: "Select Date",
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _loadCallLaterLeads,
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Result Section
  Widget _buildResult() {
    if (callLaterFuture == null) {
      return const Center(child: Text("Please select date and search"));
    }

    return FutureBuilder<CallLaterResponse>(
      future: callLaterFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.callLater.isEmpty) {
          return const Center(child: Text("No Call Later Leads"));
        }

        _allLeads = snapshot.data!.callLater;
        return _buildDataTable(paginatedLeads);
      },
    );
  }

  /// 🔹 DataTable
  Widget _buildDataTable(List<CallLaterLead> leads) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,        // space between columns
        horizontalMargin: 8,      // left/right table margin
        dataRowMinHeight: 36,
        dataRowMaxHeight: 44,
        headingRowHeight: 40,
        dividerThickness: 0.5,
        headingRowColor:
        WidgetStateProperty.all(Colors.blueGrey.shade100),
        border: TableBorder.all(color: Colors.grey.shade300),
        columns: const [
          DataColumn(label: Text("Select")),
          DataColumn(label: Text("Lead ID")),
          DataColumn(label: Text("Date / Time")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Mobile")),
          DataColumn(label: Text("Product")),
          DataColumn(label: Text("City")),

          DataColumn(label: Text("Status")),
        ],
        rows: leads.map((lead) {
          final isSelected = selectedLeadIds.contains(lead.leadId);
          return DataRow(
            selected: isSelected,
            cells: [
              DataCell(
                Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      val == true
                          ? selectedLeadIds.add(lead.leadId)
                          : selectedLeadIds.remove(lead.leadId);
                    });
                  },
                ),
              ),
              DataCell(Text(lead.leadId)),
              DataCell(Text("${_formatDate(lead.appDate)} ${lead.appTime}")),
              DataCell(Text(lead.customerName)),
              DataCell(Text(lead.mobile)),
              DataCell(Text(lead.product)),
              DataCell(Text(lead.city)),
              DataCell(Text(
                lead.statusName,
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 🔹 Pagination UI
  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: currentPage > 0
                ? () => setState(()  => currentPage--)
                : null,
            child: const Text("Previous"),
          ),
          const SizedBox(width: 12),
          Text("Page ${currentPage + 1} of $totalPages"),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: currentPage < totalPages - 1
                ? () => setState(() => currentPage++)
                : null,
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Assign Section
  Widget _buildAssignSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isLoading
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<UserTeleModel>(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Select Telecaller",
              border: OutlineInputBorder(),
            ),
            value: _selectedUser,
            items: _userList
                .map((u) => DropdownMenuItem(
              value: u,
              child: Text(u.userFname),
            ))
                .toList(),
            onChanged: (val) => setState(() => _selectedUser = val),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.assignment_turned_in),
              label: Text("Assign (${selectedLeadIds.length}) Leads"),
                onPressed: () async {
                  if (_selectedUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select telecaller")),
                    );
                    return;
                  }

                  final selectedLeads = _allLeads
                      .where((l) => selectedLeadIds.contains(l.leadId))
                      .map((item) => {
                    "lead_id": item.leadId,
                    "mobile": item.mobile,
                    "branch_id": item.branchId,
                    "status_id": item.statusId,
                    "lead_date": item.leadDate,
                    "lead_status": item.leadStatus,
                    "client_id": item.clientId,
                    "customer_name": item.customerName,
                    "product": item.product,
                    "source": item.source,
                    "res_pin": item.resPin,
                    "city": item.city,
                    "response_id": item.responseId,
                    "app_date": item.appDate,
                    "app_time": item.appTime,
                    "client_code": item.clientCode,
                    "status_name": item.statusName,
                  })
                      .toList();

                  if (selectedLeads.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select at least one lead")),
                    );
                    return;
                  }
                  for (int i = 0; i < selectedLeads.length; i++) {
                    debugPrint("----- Lead ${i + 1} -----");
                    debugPrint("Lead ID     : ${selectedLeads[i]['lead_id']}");
                    debugPrint("Mobile      : ${selectedLeads[i]['mobile']}");
                    debugPrint("Branch ID   : ${selectedLeads[i]['branch_id']}");
                    debugPrint("Status ID   : ${selectedLeads[i]['status_id']}");
                    debugPrint("Client ID   : ${selectedLeads[i]['client_id']}");
                    debugPrint("Customer    : ${selectedLeads[i]['customer_name']}");
                    debugPrint("Product     : ${selectedLeads[i]['product']}");
                    debugPrint("City        : ${selectedLeads[i]['city']}");
                  }
                  final AssignToTeleController assignToTeleController =
                  AssignToTeleController();

                  await assignToTeleController.assignToTele(
                    context: context,
                    leads: selectedLeads,
                    teleId: _selectedUser!.userId,
                    userId: widget.user_id,
                    onStartLoading: () {
                      setState(() => _isLoading = true);
                    },
                    onStopLoading: () {
                      setState(() => _isLoading = false);
                    },
                  );

                },
            ),
          ),
        ],
      ),
    );
  }
}
