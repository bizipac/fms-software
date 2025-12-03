import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fms_software/controllers/field_report_ai_controller.dart';
import 'package:fms_software/models/field_report_ai_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/get_branch_controller.dart';
import '../models/get_all_branch_model.dart';
import '../utils/app_constant.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class FieldReportAiScreen extends StatefulWidget {
  const FieldReportAiScreen({super.key});

  @override
  State<FieldReportAiScreen> createState() => _FieldReportAiScreenState();
}

class _FieldReportAiScreenState extends State<FieldReportAiScreen> {
  final BranchController _branchController = BranchController();
  List<GetAllBranchModel> _branchList = [];
  GetAllBranchModel? _selectedBranch;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController dateController = TextEditingController();

  Future<void> exportToPdf() async {
    // Request permission
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage Permission Denied")),
      );
      return;
    }

    // No data available
    if (_reportAiModel == null || _reportAiModel!.fieldexecutive.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Field Executive Report",
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),

              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(3),
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex("#E0E0E0")),
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Branch", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Lead ID", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Status", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("FE Name", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("App Date", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Client", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10))),

                    ],
                  ),

                  // Dynamic Rows
                  ..._reportAiModel!.fieldexecutive.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.branchName ?? "",style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.leadId.toString(),style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.statusId == "7" ? "PARTIAL PICKUP" : "FE ASSIGNED",
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.ufor.toString(),style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.appDate.toString(),style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.clientCode.toString(),style: pw.TextStyle(fontSize: 8)),
                        ),

                      ],
                    );
                  }).toList(),
                ],
              )
            ],
          );
        },
      ),
    );

    // Save PDF File
    Directory directory = Directory("/storage/emulated/0/Download");
    if (!directory.existsSync()) {
      directory = await getApplicationDocumentsDirectory();
    }
    final random = Random();
    int randomNumber = random.nextInt(1000);
    String filePath = "${directory.path}/FieldReportAI_$randomNumber.pdf";

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF Saved To: $filePath"),duration: Duration(seconds: 3),),
    );
  }

  bool _isLoadingBranches = true;
  FieldReportAiModel? _reportAiModel; // Nullable
  String? branchMulti;
  List<String> allowedBranchIds = [];

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    branchMulti = prefs.getString('branch_multi');

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


  /// 🔹 Fetch all branches
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
  /// 🔹 Pick Date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025, 11, 9),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      dateController.text =
      "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      setState(() {});
    }
  }

  /// 🔹 Fetch API
  Future<void> _fetchFieldReportAI({
    required String branchId,
    required String date,
  }) async {

    final data = await FieldReportAiController().fetchReports(
      branchIds: [branchId],
      client: '0',
      repDate: date,
      repDate1: date,
    );

    setState(() {
      _reportAiModel = data;
    });
  }



  @override
  Widget build(BuildContext context) {
    print("---------------------");
    print("---------------------");
    print(branchMulti);
    print("---------------------");
    print("---------------------");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: const Text("Field Report AI",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ///
              /// 🔹 Branch Selector
              ///
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

              const SizedBox(height: 10),

              ///
              /// 🔹 Date Field
              ///
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: "Select Date",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 14),

              ///
              /// 🔹 FETCH BUTTON
              ///
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      await _fetchFieldReportAI(
                        branchId: _selectedBranch!.branchId.toString(),
                        date: dateController.text.toString(),
                      );   // ✔ CORRECT
                    }
,
                    child: const Text("Fetch Report"),
                ),
              ),

              const SizedBox(height: 20),

              ///
              /// 🔹 SHOW REPORT TABLE (Optional)
              ///
              if (_reportAiModel != null)
                Text("Report Loaded ✔", style: TextStyle(fontSize: 16)),
              if (_reportAiModel != null)
                _reportAiModel!.fieldexecutive.isEmpty
                    ? const Text(
                  "No records found",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey),
                    headingRowColor:
                    WidgetStateProperty.all(Colors.blue.shade100),

                    columns: const [
                      DataColumn(label: Text("Branch")),
                      DataColumn(label: Text("LeadID")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Call Attempt")),
                      DataColumn(label: Text("FEName")),
                      DataColumn(label: Text("App Date")),
                      DataColumn(label: Text("App Time")),
                      DataColumn(label: Text("Pincode")),
                      DataColumn(label: Text("Client")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Mobile Number")),
                      DataColumn(label: Text("Remarks")),
                      DataColumn(label: Text("First Call Date & Time")),
                      DataColumn(label: Text("Last Call Date & Time")),
                      DataColumn(label: Text("Last Call Type")),
                      DataColumn(label: Text("Last Call Status")),
                      DataColumn(label: Text("Last Call Duration")),
                      DataColumn(label: Text("Recording")),

                    ],
                    rows: _reportAiModel!.fieldexecutive.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item.branchName ?? "-")),
                          DataCell(Text(item.leadId.toString())),
                          DataCell(item.statusId=="7"?Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.green,   // ✅ Background green
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "PARTIAL PICKUP",
                              style: TextStyle(
                                color: Colors.white,   // ✅ Text white
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ) :Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,   // ✅ Background green
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "FE ASSIGNED",
                              style: TextStyle(
                                color: Colors.white,   // ✅ Text white
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                          ),
                          DataCell(Text(item.callCount ?? "-")),
                          DataCell(Text(item.ufor ?? "-")),
                          DataCell(Text(item.appDate ?? "-")),
                          DataCell(Text(item.appTime ?? "-")),
                          DataCell(Text(item.appPin ?? "-")),
                          DataCell(Text(item.clientCode ?? "-")),
                          DataCell(Text(item.customerName ?? "-")),
                          DataCell(Text(item.mobile ?? "-")),
                          DataCell(Text(item.remarks ?? "-")),
                          DataCell(Text(item.firstcall ?? "-")),
                          DataCell(Text(item.lastcall ?? "-")),
                          DataCell(Text(item.callType ?? "-")),
                          DataCell(Text(item.dialCallStatus ?? "-")),
                          DataCell(Text(item.dialCallDuration ?? "-")),
                          //DataCell(Text(item.recordingUrl ?? "-")),
                          DataCell(
                            item.recordingUrl == null || item.recordingUrl!.isEmpty
                                ? const Text("-")
                                : IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.green),
                              onPressed: () async {
                                try {
                                  await _audioPlayer.stop(); // stop old audio
                                  await _audioPlayer.play(UrlSource(item.recordingUrl!));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Audio Error: $e")),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: exportToPdf,
        child: const Icon(Icons.download),
      ),
    );
  }
}
