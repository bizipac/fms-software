import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fms_software/models/lead_status-history_model.dart';
import 'package:fms_software/views/transfer_lead_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/fe_calls_controllers.dart';
import '../controllers/get_branch_controller.dart';
import '../controllers/get_lead_details_controllers.dart';
import '../controllers/lead_status_history-controller.dart';
import '../models/get_all_branch_model.dart';
import '../utils/app_constant.dart';

class TransferViewScreen extends StatefulWidget {
  const TransferViewScreen({super.key});

  @override
  State<TransferViewScreen> createState() => _TransferViewScreenState();
}

class _TransferViewScreenState extends State<TransferViewScreen> {
  final GetTransferLeadController controller = Get.put(GetTransferLeadController());
  final LeadHistoryController _leadstatuscontroller = Get.put(LeadHistoryController());
  final TextEditingController searchController = TextEditingController();

  final BranchController _branchController = BranchController();
  List<GetAllBranchModel> _branchList = [];
  GetAllBranchModel? _selectedBranch;
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
  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open browser");
    }
  }
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentUrl;
  bool _isPlaying = false;
  String? branchMulti;
  int? userid,branchID;
  bool _isLoadingBranches = true;
  List<String> allowedBranchIds = [];
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    branchMulti = prefs.getString('branch_multi');
    userid = prefs.getInt('user_id');
    branchID = prefs.getInt('branch_id');
    if (branchMulti != null && branchMulti!.isNotEmpty) {
      allowedBranchIds = branchMulti!.split(','); // ["1","5","8"]
    }
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _loadBranches();
    loadUserData();
  }
  Future<void> _loadBranches() async {
    try {
      final response = await _branchController.fetchBranches();

      // API से पूरी branch list आती होगी
      List<GetAllBranchModel> allBranches = response;

      // 🔥 Filter only branches that match branchMulti
      List<GetAllBranchModel> filtered = allBranches.where((b) {
        return allowedBranchIds.contains(b.branchId.toString());
      }).toList();

      setState(() {
        _branchList = filtered;   // 🔥 अब dropdown में सिर्फ filtered branches आएंगी
        _isLoadingBranches = false;
      });
    } catch (e) {
      setState(() => _isLoadingBranches = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading branches: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text("Transfer View Screen", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            GestureDetector(
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
            const SizedBox(height: 20),
            // 🔍 Search Field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Enter Mobile / Lead ID",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          final mobile = searchController.text.trim();
                          if (mobile.isNotEmpty) {
                           // await controller.fetchTransferLeads(mobile,_selectedBranch!.branchId.toString());
                           // // await controller.fetchTransferLeads(mobile,"${branchId!.toString()}");
                           //  setState(() {
                           //  });
                            final selectedId = _selectedBranch?.branchId?.toString() ?? branchID.toString();
                            print(selectedId);
                            await controller.fetchTransferLeads(mobile, selectedId);
                            setState(() {});

                          } else {
                            Get.snackbar("Error", "Please enter a mobile or lead ID");
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🧭 Main content scrolls
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final details = controller.leadDetails.value;
                if (details == null || details.leadMaster.isEmpty) {
                  return const Center(child: Text("No leads found"));
                }
                final leads = details.leadMaster;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🧾 Leads Table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                          MaterialStateProperty.all(Colors.blueGrey.shade100),
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnSpacing: 15,        // space between columns
                          horizontalMargin: 12,      // left/right table margin
                          dataRowMinHeight: 36,
                          dataRowMaxHeight: 44,
                          headingRowHeight: 40,
                          dividerThickness: 0.5,
                          columns: const [
                            DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Lead ID", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Client", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Lead Date", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Branch", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Mobile", style: TextStyle(fontWeight: FontWeight.bold))),

                            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: leads.map((lead) {
                            return DataRow(
                              cells: [
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.work_history, color: Colors.redAccent),
                                      onPressed: () async {
                                        final leadId = lead.leadId!.toString();
                                        if (leadId != null) {
                                          await _leadstatuscontroller.fetchLeadHistory(leadId);
                                          List<CrmRecord> leadHistory = _leadstatuscontroller.historyList;
                                          print("✅ Lead history fetched: ${leadHistory.length} items");
                                        } else {
                                          Get.snackbar("Error", "Lead ID is missing");
                                        }
                                      },
                                    ),
                                    (lead.statusId == 11 || lead.statusId == 15)?SizedBox.shrink():IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.arrow_circle_right_outlined, color: Colors.redAccent),
                                      onPressed: () {

                                        final selectedBranchId = _selectedBranch?.branchId?.toString() ?? branchID.toString();
                                        Get.to(() => TransferLeadScreen(leadMaster: lead,user_id:userid.toString(),branchid:selectedBranchId));
                                      },
                                    ),
                                  ],
                                )),
                                DataCell(
                                  TextButton(
                                    onPressed: () async {
                                      final leadId = lead.leadId.toString();

                                      // Fetch history
                                      await _leadstatuscontroller.fetchLeadHistory(leadId);
                                      List<CrmRecord> history = _leadstatuscontroller.historyList;

                                      print("Fetched history: ${history.length}");

                                      CrmRecord? latestRecord;

                                      if (history.isNotEmpty) {
                                        // Sort history by timestamp (newest first)
                                        history.sort((a, b) {
                                          DateTime dateA = DateTime.tryParse(a.resTimestamp ?? "") ?? DateTime(2000);
                                          DateTime dateB = DateTime.tryParse(b.resTimestamp ?? "") ?? DateTime(2000);
                                          return dateB.compareTo(dateA); // descending
                                        });

                                        latestRecord = history.first; // now this is latest by date
                                      }

                                      // Show dialog
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Latest Lead Status"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Response: ${latestRecord?.response ?? 'No Response'}"),
                                                Text("Updated By: ${latestRecord?.uby ?? '-'}"),
                                                Text("Date & Time: ${latestRecord?.resTimestamp ?? '-'}"),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(lead.leadId.toString()),
                                  ),
                                ),
                                DataCell(Text(lead.clientCode ?? 'N/A')),
                                DataCell(Text(_formatDate(lead.leadDate ?? 'N/A'))),
                                DataCell(Text(lead.branchName ?? 'N/A')),
                                DataCell(Text(lead.mobile ?? 'N/A')),

                                DataCell(Text(lead.customerName ?? 'N/A')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 📋 History section
                      const Text("📋 Status History",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      Obx(() {
                        if (_leadstatuscontroller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (_leadstatuscontroller.historyList.isEmpty) {
                          return const Text("No history found");
                        }

                        final history = _leadstatuscontroller.historyList;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade100),
                            border: TableBorder.all(color: Colors.grey.shade300),
                            dataRowMinHeight: 32,
                            dataRowMaxHeight: 45,
                            columns: const [
                              DataColumn(label: Text("Sr. No", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Response", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Updated By", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Timestamp", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(history.length, (index) {
                              final item = history[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text("${index + 1}")),
                                  DataCell(Text(item.response ?? 'No Response')),
                                  DataCell(Text(item.uby ?? '-')),
                                  DataCell(Text(item.resTimestamp ?? '-')),
                                ],
                              );
                            }),
                          ),
                        );
                      }),

                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
