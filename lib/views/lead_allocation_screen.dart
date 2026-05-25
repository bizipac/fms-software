import 'package:flutter/material.dart';
import 'package:fms_software/controllers/appfixed_controller.dart';
import 'package:fms_software/models/appfixed_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../controllers/assign_fe_controller.dart';
import '../controllers/assign_to_tele_controller.dart';
import '../controllers/userlist_controller.dart';
import '../models/userlist_model.dart';
import '../utils/app_constant.dart';

class LeadAllocationScreen extends StatefulWidget {
  final String branchid;
  const LeadAllocationScreen({super.key, required this.branchid});

  @override
  State<LeadAllocationScreen> createState() => _LeadAllocationScreenState();
}

class _LeadAllocationScreenState extends State<LeadAllocationScreen> {
  final AppFixedController appFixedController = AppFixedController();

  bool _loading = false;
  List<AppFixedModel> _appFixedList = [];
  String _searchQuery = "";

  int? userId, branchId;
  bool isLoadingUser = true;

  // Pagination
  int _currentPage = 0;
  final int _rowsPerPage = 8;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadUsers1();
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
  // 🔹 Load user_id & branch_id from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getInt('user_id');
      branchId = prefs.getInt('branch_id');
      isLoadingUser = false;
    });
  }



  // 🔹 Load Appointment Fixed Data
  Future<void> loadFixedData() async {
    if (branchId == null || userId == null) return;
    setState(() {
      _loading = true;
    });

    final data = await appFixedController.fetchAppFixed(
      branch: "$branchId",
      userid: "$userId",
      client: "0",
    );

    setState(() {
      _appFixedList = data;
      _loading = false;
      _currentPage = 0; // Reset to first page
    });
  }
  bool loadingssg = false;
  final AssignToTeleController _assignControllers = AssignToTeleController();
  final AssignToFeController controller = AssignToFeController();

  // 🔹 Get selected leads
  void getSelectedLeads({
    required String userid,
    required String feuserid,
    bool fesms = true, // optional SMS flag
  }) {
    List<Map<String, dynamic>> selectedLeads = _appFixedList
        .where((item) => item.isSelected)
        .map((item) => item.toMap())
        .toList();

    if (selectedLeads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one lead")),
      );
      return;
    }

    print("Selected Leads Map = $selectedLeads");
    print("User Id = $userid");
    print("FE User Id = $feuserid");

    callAssignApi(
      selectedLeads: selectedLeads,
      userid: userid,
      feuserid: feuserid,
      fesms: fesms,
    );
  }

  Future<void> callAssignApi({
    required List<Map<String, dynamic>> selectedLeads,
    required String userid,
    required String feuserid,
    bool fesms = true,
  }) async {
    try {
      Map<String, dynamic> response = await controller.assignLead(
        leads: selectedLeads, // ❌ Remove extra []
        config: {
          "teleid": feuserid,
          "fesms": fesms,
        },
        userid: userid,
      );

      print("🎉 API Response = $response");
      setState(() {
        selectedLeads.clear();
        _appFixedList.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lead Allocation Successfully")),
      );

    } catch (e) {
      print("❌ API Error = $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }


  // 🔹 Get paginated list
  List<AppFixedModel> get paginatedList {
    final filteredList = _appFixedList.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.leadId.toLowerCase().contains(query) ||
          item.customerName.toLowerCase().contains(query) ||
          item.appPin.toLowerCase().contains(query) ||
          item.product.toLowerCase().contains(query);
    }).toList();

    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    if (start >= filteredList.length) return [];

    return filteredList.sublist(start, end > filteredList.length ? filteredList.length : end);
  }

  // 🔹 Total pages
  int get totalPages {
    final filteredList = _appFixedList.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.leadId.toLowerCase().contains(query) ||
          item.customerName.toLowerCase().contains(query) ||
          item.appPin.toLowerCase().contains(query) ||
          item.product.toLowerCase().contains(query);
    }).toList();

    return (filteredList.length / _rowsPerPage).ceil();
  }

  final UserController _controller = UserController();

  List<UserData1> _users = [];
  UserData1? _selectedUser;
  bool loading = true;
  bool fesms = false;
  bool customersms = false;
  final UserController userController1=UserController();
  Future<void> loadUsers1() async {
    try {
      final result = await _controller.fetchUsers(widget.branchid);

      setState(() {
        _users = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: const Text("Lead Allocation", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(   // MAIN SCROLL VIEW (vertical)
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 🔵 FETCH BUTTON
            Center(
              child: Container(
                width: 330,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  onPressed: loadFixedData,
                  child: const Text("FETCH LEADS",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 🔵 ALLOCATE BUTTON
            const SizedBox(height: 10),
            // 🔍 SEARCH BOX
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by Lead ID, Name, Pincode, Product...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // LOADING INDICATOR
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (paginatedList.isEmpty)
              const Center(
                child: Text("No Leads Found", style: TextStyle(fontSize: 16)),
              )
            else
              Column(
                children: [
                  // 🔹 DATA TABLE (horizontal scrolling only)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 15,        // space between columns
                      horizontalMargin: 12,      // left/right table margin
                      dataRowMinHeight: 36,
                      dataRowMaxHeight: 44,
                      headingRowHeight: 40,
                      dividerThickness: 0.5,
                      border: TableBorder.all(color: Colors.grey.shade300),
                      headingRowColor:
                      MaterialStateColor.resolveWith(
                              (states) => Colors.blue.shade50),

                      columns: [
                        DataColumn(
                          label: Checkbox(
                            value: paginatedList.every((item) => item.isSelected),
                            onChanged: (value) {
                              setState(() {
                                for (var item in paginatedList) {
                                  item.isSelected = value!;
                                }
                              });
                            },
                          ),
                        ),
                        const DataColumn(label: Text("Lead ID")),
                        const DataColumn(label: Text("Pincode")),
                        const DataColumn(label: Text("App Date")),
                        const DataColumn(label: Text("Address")),
                        const DataColumn(label: Text("App Time")),
                        const DataColumn(label: Text("Client")),
                        const DataColumn(label: Text("Lead Date")),
                        const DataColumn(label: Text("Product")),
                        const DataColumn(label: Text("Name")),
                      ],

                      rows: paginatedList.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Checkbox(
                                value: item.isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    item.isSelected = value!;
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(item.leadId)),
                            DataCell(Text(item.appPin)),
                            DataCell(Text(_formatDate(item.appDate))),
                            DataCell(Text(item.appAdd)),
                            DataCell(Text(item.appTime)),
                            DataCell(Text(item.clientId)),
                            DataCell(Text(item.leadDate)),
                            DataCell(Text(item.product)),
                            DataCell(Text(item.customerName.isEmpty
                                ? "No Name"
                                : item.customerName)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 PAGINATION BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _currentPage > 0
                            ? () {
                          setState(() => _currentPage--);
                        }
                            : null,
                        child: const Text("Previous"),
                      ),

                      Text(
                        "Page ${_currentPage + 1} of $totalPages",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      TextButton(
                        onPressed: _currentPage < totalPages - 1
                            ? () {
                          setState(() => _currentPage++);
                        }
                            : null,
                        child: const Text("Next"),
                      ),
                    ],
                  ),
                ],
              ),
            //
            _appFixedList.isEmpty?SizedBox.shrink():Padding(
              padding: const EdgeInsets.all(16),
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select User",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🌟 STYLED DROPDOWN
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<UserData1>(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      hint: const Text(
                        "Choose User",
                        style: TextStyle(fontSize: 15),
                      ),
                      value: _selectedUser,
                      items: _users.map((user) {
                        return DropdownMenuItem(
                          value: user,
                          child: Text(
                            user.userFname,
                            style: const TextStyle(fontSize: 15),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUser = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🌟 SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a user"),
                            ),
                          );
                          return;
                        }

                        // 🔥 SELECTED USER ID GET HERE
                        print("Selected User ID: ${_selectedUser!.userId}");
                        print("Selected User ID: ${userId}");
                        getSelectedLeads(userid: '$userId', feuserid: '${_selectedUser!.userId}');
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(
                        //       "Selected User: ${_selectedUser!.userFname} (ID: ${_selectedUser!.userId}) (UserId: ${userId})",
                        //     ),
                        //
                        //   ),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
