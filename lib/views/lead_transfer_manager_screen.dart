import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/get_branch_controller.dart';
import '../controllers/lead_transfer_branch_controller.dart';
import '../controllers/lead_transfer_controller.dart';
import '../models/get_all_branch_model.dart';
import '../models/lead_transfer_model.dart';
import '../utils/app_constant.dart';

class LeadTransferManagerScreen extends StatefulWidget {
  final String branchid;
  const LeadTransferManagerScreen({super.key, required this.branchid});

  @override
  State<LeadTransferManagerScreen> createState() => _LeadTransferManagerScreenState();
}

class _LeadTransferManagerScreenState extends State<LeadTransferManagerScreen> {
  TextEditingController mobileController = TextEditingController();

  final BranchController _branchController = BranchController();

  List<GetAllBranchModel> _branchList = [];
  GetAllBranchModel? _selectedBranch;
  bool _isLoading = true;
  List<String> allowedBranchIds = [];

  LeadMaster? leadData;
  bool isLoading = false;

  Future<void> searchLead() async {
    setState(() => isLoading = true);

    final result = await LeadTransferService()
        .fetchLead(widget.branchid, mobileController.text.trim());

    setState(() {
      isLoading = false;
      leadData = result?.leadMaster.isNotEmpty == true
          ? result!.leadMaster.first
          : null;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserData(); // load on start
    loadBranches();
  }
  String? branchMulti;
  int? userID,branchID;
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    branchMulti = prefs.getString('branch_multi');
    branchID = prefs.getInt('branch_id');
    userID = prefs.getInt('user_id');
    if (branchMulti != null && branchMulti!.isNotEmpty) {
      allowedBranchIds = branchMulti!.split(','); // ["1","5","8"]
    }
    setState(() {});
  }
  List<Map<String, dynamic>> selectedLeads = [];

  Future<void> sendLeadTransfer() async {
    setState(() => isLoading = true);

    bool success = await LeadTransferBranchService().transferLead(
      userId: userID.toString(),
      branchId: _selectedBranch!.branchId.toString(),
      leadList: selectedLeads,
    );


    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lead transferred successfully")),
    );
  }
  Future<void> loadBranches() async {
    try {
      List<GetAllBranchModel> branches = await _branchController
          .fetchBranches();
      // API से पूरी branch list आती होगी
      List<GetAllBranchModel> allBranches = branches;

      // 🔥 Filter only branches that match branchMulti
      List<GetAllBranchModel> filtered = allBranches.where((b) {
        return allowedBranchIds.contains(b.branchId.toString());
      }).toList();
      setState(() {
        _branchList =
            filtered; // 🔥 अब dropdown में सिर्फ filtered branches आएंगी
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text("Lead Transfer Manager", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              /// 🔍 SEARCH BAR
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter Mobile / Lead ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: searchLead,
                    child: Text("Search"),
                  )
                ],
              ),

              SizedBox(height: 20),

              isLoading
                  ? CircularProgressIndicator()
                  : leadData == null
                  ? Text("No Data Found")
                  : leadCard(leadData!),

              (leadData==null)?SizedBox.shrink():GestureDetector(
                onTap: () async {
                  final selected = await showDialog<GetAllBranchModel>(
                    context: context,
                    builder: (context) {
                      TextEditingController searchController =
                      TextEditingController();
                      List<GetAllBranchModel> filteredList =
                      List.from(_branchList);

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text("Select Branch"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    hintText: "Search branch...",
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      filteredList = _branchList
                                          .where((b) => b.branchName
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                          .toList();
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 250,
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final branch = filteredList[index];
                                      return ListTile(
                                        title: Text(branch.branchName),
                                        onTap: () {
                                          Navigator.pop(context, branch);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );

                  if (selected != null) {
                    setState(() => _selectedBranch = selected);
                  }
                },
                child: AbsorbPointer(
                  child: DropdownButtonFormField<GetAllBranchModel>(
                    value: _selectedBranch,
                    decoration: const InputDecoration(
                      labelText: "Select Branch",
                      border: OutlineInputBorder(),
                    ),
                    items: _branchList.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch.branchName),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
              ),
              SizedBox(height: 20,),
              (leadData==null)?SizedBox.shrink():ElevatedButton(
                onPressed: sendLeadTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text("Save",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🟦 LEAD DETAILS CARD UI
  /// 🟦 LEAD DETAILS CARD UI
  Widget leadCard(LeadMaster lead) {
    // Check if this lead is already selected
    bool isSelected = selectedLeads.any((item) => item["lead_id"] == lead.leadId);

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✔️ Checkbox for selection
            Checkbox(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    // ADD lead to selected list
                    selectedLeads.add({
                      "lead_id": lead.leadId,
                      "mobile": lead.mobile,
                      "branch_id": lead.branchId,
                    });
                  } else {
                    // REMOVE lead
                    selectedLeads.removeWhere(
                          (e) => e["lead_id"] == lead.leadId,
                    );
                  }
                });

                print("Selected Leads: $selectedLeads");
              },
            ),

            /// 📋 Lead Data Table
            Expanded(
              child: Table(
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(5),
                },
                children: [
                  tableRow("Lead ID", lead.leadId),
                  tableRow("Name", lead.customerName),
                  tableRow("Mobile", lead.mobile),
                  tableRow("Branch", lead.branchName ?? "-"),
                  tableRow("City", lead.city ?? "-"),
                  tableRow("Status", lead.statusName ?? "-"),
                  tableRow("Lead Date", lead.leadDate),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow tableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(value),
        ),
      ],
    );
  }

}
