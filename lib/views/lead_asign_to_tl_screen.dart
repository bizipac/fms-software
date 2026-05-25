import 'package:flutter/material.dart';

import '../controllers/assign_to_tele_controller.dart';
import '../controllers/fresh_lead-controller.dart';
import '../controllers/user_tele_controller.dart';
import '../models/fresh_lead_model.dart';
import '../models/user_tele_response_model.dart';
import '../utils/app_constant.dart';

class FreshLeadScreen extends StatefulWidget {
  final String user_id;
  final String branchid;

  const FreshLeadScreen({
    super.key,
    required this.user_id,
    required this.branchid,
  });

  @override
  State<FreshLeadScreen> createState() => _FreshLeadScreenState();
}

class _FreshLeadScreenState extends State<FreshLeadScreen> {
  final FreshLeadController controller = FreshLeadController();

  bool loading = false;

  // Pagination
  int _currentPage = 1;
  final int _perPage = 8;
  bool _hasMore = false;

  // Main lists
  List<FreshLeadItem> allLeads = [];
  List<FreshLeadItem> leadList = [];
  List<bool> selectedList = [];
  bool isAllSelected = false;
  final ScrollController _scrollController = ScrollController();

  // Search Controller
  final TextEditingController _searchController = TextEditingController();

  // Load Leads with infinite scroll (local pagination)
  Future<void> loadLeads({bool loadMore = false}) async {
    if (loading) return;

    setState(() => loading = true);

    // Always fetch all leads ONCE from API
    final res = await controller.fetchFreshLeads(
      branch: widget.branchid,
      client: "0",
    );

    if (!loadMore) {
      allLeads = res?.fresh ?? [];
      leadList.clear();
      selectedList.clear();
      _currentPage = 1;
    }

    applySearch(); // Auto apply search filter

    setState(() => loading = false);
  }

  // -------------------------------
  // SEARCH FUNCTION
  // -------------------------------

  void applySearch() {
    String query = _searchController.text.trim().toLowerCase();

    List<FreshLeadItem> filteredList = [];

    if (query.isEmpty) {
      // NORMAL PAGINATION
      int start = (_currentPage - 1) * _perPage;
      int end = start + _perPage;

      if (start < allLeads.length) {
        filteredList = allLeads.sublist(
          start,
          end > allLeads.length ? allLeads.length : end,
        );
        _hasMore = end < allLeads.length;
      }
    } else {
      // SEARCH (no pagination)
      filteredList = allLeads.where((item) {
        return (item.leadId?.toLowerCase().contains(query) ?? false) ||
            (item.customerName?.toLowerCase().contains(query) ?? false);
      }).toList();

      _hasMore = false; // disable load more on search
    }

    leadList = filteredList;
    selectedList = List.generate(leadList.length, (i) => false);
    setState(() {});
  }

  // User Tele Logic
  final UserListController _controllerTele = UserListController();
  List<UserTeleModel> _userList = [];
  UserTeleModel? _selectedUser;
  bool _isLoading = true;

  Future<void> loadUsers() async {
    try {
      final result = await _controllerTele.fetchUsers(widget.branchid, "4");

      final filteredUsers = result.where((user) {
        List<String> branches = user.branchMulti.split(",");
        return branches.contains(widget.branchid);
      }).toList();

      setState(() {
        _userList = filteredUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    loadUsers();

    // Infinite scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMore && !loading && _searchController.text.isEmpty) {
          _currentPage++;
          loadLeads(loadMore: true);
        }
      }
    });

    // Auto-search listener
    _searchController.addListener(() {
      applySearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text(
          'Assign Lead TL',
          style: TextStyle(
            color: AppConstant.appBarWhiteColor,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: 325,
              child: ElevatedButton(
                onPressed: () {
                  _currentPage = 1;
                  loadLeads(loadMore: false);
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
                  "Fetch Fresh Leads",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------------
            // SEARCH BAR
            // ---------------------------
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by Lead ID or Name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (loading && leadList.isEmpty)
              const Center(child: CircularProgressIndicator()),

            if (!loading && leadList.isEmpty)
              const Text("No Fresh Leads Found"),

            if (leadList.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _scrollController, // Vertical scroll
                    scrollDirection: Axis.vertical,
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
                      columns: [
                        DataColumn(
                          label: Checkbox(
                            value: isAllSelected,
                            onChanged: (value) {
                              setState(() {
                                isAllSelected = value ?? false;
                                for (int i = 0; i < selectedList.length; i++) {
                                  selectedList[i] = isAllSelected;
                                }
                              });
                            },
                          ),
                        ),
                        const DataColumn(label: Text("Lead ID")),
                        const DataColumn(label: Text("Name")),
                        const DataColumn(label: Text("Mobile")),
                        const DataColumn(label: Text("Product")),
                        const DataColumn(label: Text("City")),
                        const DataColumn(label: Text("Status")),
                      ],
                      rows: List.generate(leadList.length, (index) {
                        final item = leadList[index];
                        return DataRow(
                          cells: [
                            DataCell(
                              Checkbox(
                                value: selectedList[index],
                                onChanged: (value) {
                                  setState(() {
                                    selectedList[index] = value ?? false;
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(item.leadId ?? "")),
                            DataCell(Text(item.customerName ?? "")),
                            DataCell(Text(item.mobile ?? "")),
                            DataCell(Text(item.product ?? "")),
                            DataCell(Text(item.city ?? "")),
                            DataCell(Text(item.statusName ?? "")),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),

            (leadList.isEmpty)
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                children: [
                  DropdownButtonFormField<UserTeleModel>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Select Telecaller",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedUser,
                    items: _userList.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(
                          "${user.userFname} ",//(${user.userMobile})",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a Telecaller")),
                        );
                        return;
                      }
                      // Collect Selected Leads
                      List<Map<String, dynamic>> selectedLeads = [];

                      for (int i = 0; i < leadList.length; i++) {
                        if (selectedList[i]) {
                          final item = leadList[i];

                          selectedLeads.add({
                            "lead_id": item.leadId,
                            "client_id": item.clientId,
                            "branch_id": item.branchId,
                            "res_pin": item.resPin,
                            "source": item.source,
                            "product": item.product,
                            "customer_name": item.customerName,
                            "case_id": item.caseId,
                            "mobile": item.mobile,
                            "form_no": item.formNo,
                            "status_id": item.statusId,
                            "client_code": item.clientCode,
                            "status_name": item.statusName,
                            "city": item.city,
                          });
                        }
                      }

                      if (selectedLeads.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select at least one lead")),
                        );
                        return;
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Assign To Tele"),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
