import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fms_software/models/lead_status-history_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/fe_calls_controllers.dart';
import '../controllers/get_lead_details_controllers.dart';
import '../controllers/lead_status_history-controller.dart';
import '../utils/app_constant.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({super.key});

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final GetLeadDetailsController controller = Get.put(GetLeadDetailsController());
  final LeadHistoryController _leadstatuscontroller = Get.put(LeadHistoryController());
  final TextEditingController searchController = TextEditingController();

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open browser");
    }
  }
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentUrl;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text("Query Screen", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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

                          final query = searchController.text.trim();
                          if (query.isNotEmpty) {
                            await controller.fetchLeads(query);
                            setState(() {

                            });
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
                          dataRowMinHeight: 10,
                          dataRowMaxHeight: 35,
                          columns: const [
                            DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Lead ID", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Client", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Branch", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Mobile", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Lead Date", style: TextStyle(fontWeight: FontWeight.bold))),
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
                                      icon: const Icon(Icons.history, color: Colors.green),
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
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(Icons.image, color: Colors.blue.shade400),
                                      onPressed: () {
                                        final url =
                                            "https://fms.bizipac.com/secureapi/civ_deactive.php?lead_id=${lead.leadId}";
                                        _launchInBrowser(url);
                                      },
                                    ),
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(Icons.call, color: Colors.blue.shade400),
                                      onPressed: () async {
                                        final leadId = lead.leadId.toString();

                                        // Show loading while fetching
                                        Get.dialog(
                                          const Center(child: CircularProgressIndicator()),
                                          barrierDismissible: false,
                                        );

                                        try {
                                          final historyList = await fetchLeadCallHistory(leadId);
                                          Get.back(); // close loading dialog

                                          if (historyList.isEmpty) {
                                            Get.snackbar("No Data", "No call history found for this lead");
                                            return;
                                          }

                                          // ✅ Show data in AlertDialog
                                          showDialog(
                                            context: Get.context!,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("📞 Lead Call History",style: TextStyle(fontSize: 18),),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: DataTable(
                                                      headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade100),
                                                      columns: const [
                                                        DataColumn(label: Text("Timestamp")),
                                                        DataColumn(label: Text("Fe Name")),
                                                        DataColumn(label: Text("Fe Number")),
                                                        DataColumn(label: Text("Status")),
                                                        DataColumn(label: Text("Record")),
                                                      ],
                                                      rows: historyList.map((item) {
                                                        return DataRow(cells: [
                                                          DataCell(Text(item["startTime"]?.toString() ?? "-")),
                                                          DataCell(Text(item["user_fname"]?.toString() ?? "-")),
                                                          DataCell(Text(item["CallFrom"]?.toString() ?? "-")),
                                                          DataCell(Row(
                                                            children: [
                                                              Text(item["DialCallStatus"]?.toString() ?? "-"),
                                                              SizedBox(width: 10,),
                                                              Text(item["DialCallDuration"]?.toString() ?? "-")
                                                            ],
                                                          )),
                                                          DataCell(
                                                            item["RecordingUrl"] != ""
                                                                ? IconButton(
                                                              icon: Icon(
                                                                _isPlaying && _currentUrl == item["RecordingUrl"]
                                                                    ? Icons.pause
                                                                    : Icons.play_arrow,
                                                                color: Colors.green,
                                                              ),
                                                                onPressed: () async {
                                                                  final url = item["RecordingUrl"];

                                                                  if (_isPlaying && _currentUrl == url) {
                                                                    // Pause if same audio is playing
                                                                    await _audioPlayer.pause();
                                                                    setState(() {
                                                                      _isPlaying = false;
                                                                    });
                                                                  } else {
                                                                    await _audioPlayer.stop();
                                                                    await _audioPlayer.play(UrlSource(url)); // ✅ returns void, no need to store result

                                                                    setState(() {
                                                                      _isPlaying = true;
                                                                      _currentUrl = url;
                                                                    });

                                                                    // When playback completes
                                                                    _audioPlayer.onPlayerComplete.listen((_) {
                                                                      setState(() {
                                                                        _isPlaying = false;
                                                                        _currentUrl = null;
                                                                      });
                                                                    });
                                                                  }
                                                                }

                                                            )
                                                                : const Text("-"),
                                                          ),

                                                        ]);
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text("Close"),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } catch (e) {
                                          Get.back(); // close loading dialog
                                          Get.snackbar("Error", "Something went wrong: $e");
                                        }
                                      },
                                    ),

                                  ],
                                )),
                                DataCell(Text(lead.leadId.toString())),
                                DataCell(Text(lead.clientCode ?? 'N/A')),
                                DataCell(Text(lead.branchName ?? 'N/A')),
                                DataCell(Text(lead.mobile ?? 'N/A')),
                                DataCell(Text(lead.leadDate ?? 'N/A')),
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
