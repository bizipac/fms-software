import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fms_software/controllers/field_report_ai_controller.dart';
import 'package:fms_software/models/field_report_ai_model.dart';
import 'package:intl/intl.dart';
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
                    0: pw.FlexColumnWidth(2), // Branch
                    1: pw.FlexColumnWidth(2), // Lead ID
                    2: pw.FlexColumnWidth(3), // Status
                    3: pw.FlexColumnWidth(3), // FE Name
                    4: pw.FlexColumnWidth(3), // App Date
                    5: pw.FlexColumnWidth(2), // Client
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

    print(filePath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF Saved To: $filePath"),duration: Duration(seconds: 3),),
    );
  }
  //final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentUrl;
  bool _isPlaying = false;

  bool isValidAudioUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    if (url.endsWith("file=")) return false;
    if (!url.contains("file=")) return false;
    if (url.length < 40) return false; // too short to be a real file
    return true;
  }
  Future<void> playAudio(String url) async {
    try {
      // 🔁 SAME AUDIO → TOGGLE PAUSE
      if (_isPlaying && _currentUrl == url) {
        await _audioPlayer.stop();
        _currentUrl = null;

        setState(() {
          _isPlaying = false;
        });
        return;
      }

      // ▶️ DIFFERENT AUDIO → STOP OLD & PLAY NEW
      if (_currentUrl != url) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(UrlSource(url));

      setState(() {
        _currentUrl = url;
        _isPlaying = true;
      });
    } catch (e) {
      setState(() {
        _isPlaying = false;
        _currentUrl = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot play audio: Invalid file URL")),
      );
    }
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
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentUrl = null;
      });
    });
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
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
    print(branchMulti);
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
                      );// ✔ CORRECT
                    }
,                  style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                    child: const Text("Fetch Report",style: TextStyle(color: Colors.white),),
                ),
              ),

              const SizedBox(height: 20),

              ///
              /// 🔹 SHOW REPORT TABLE (Optional)
              ///
              if (_reportAiModel != null)
                Text("Report Loaded ✔ ", style: TextStyle(fontSize: 16)),
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
                    columnSpacing: 12,        // space between columns
                    horizontalMargin: 8,      // left/right table margin
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 44,
                    headingRowHeight: 40,
                    dividerThickness: 0.5,
                    columns: [
                      const DataColumn(label: Text("Recording")),
                      DataColumn(label: Text("LeadID (${_reportAiModel!.leadCount})")),
                      const DataColumn(label: Text("Status")),
                      const DataColumn(label: Text("Call Attempt")),
                      const DataColumn(label: Text("FEName")),
                      const DataColumn(label: Text("App Date")),
                      const DataColumn(label: Text("App Time")),
                      const DataColumn(label: Text("Pincode")),
                      const DataColumn(label: Text("Client")),
                      const DataColumn(label: Text("Name")),
                      const DataColumn(label: Text("Remarks")),
                      const DataColumn(label: Text("First Call Date & Time")),
                      const DataColumn(label: Text("Last Call Date & Time")),
                      const DataColumn(label: Text("Last Call Type")),
                      const DataColumn(label: Text("Last Call Status")),
                      const DataColumn(label: Text("Last Call Duration")),


                    ],
                    rows: _reportAiModel!.fieldexecutive.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(
                            isValidAudioUrl(item.recordingUrl)
                                ? IconButton(
                              icon: Icon(
                                _isPlaying && _currentUrl == item.recordingUrl
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.green,
                              ),
                              onPressed: () => playAudio(item.recordingUrl!),
                            )
                                : const Text("-"),
                          ),
                          DataCell(Text(item.leadId.toString())),
                          DataCell(
                              item.statusId=="1"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "Fresh",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="2"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                    "POSTPONED",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="3"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "POSTPONED",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="4"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "RTO",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="5"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "POSTPONED",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="6"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,   // ✅ Background green
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
                              ):item.statusId=="7"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,   // ✅ Background green
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
                              ):item.statusId=="8"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "PICKUP",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="9"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "RTO",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="10"?Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,   // ✅ Background green
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "POSTPONED",
                              style: TextStyle(
                                color: Colors.black87,   // ✅ Text white
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ):item.statusId=="11"?Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.green,   // ✅ Background green
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "PICKUP",
                              style: TextStyle(
                                color: Colors.white,   // ✅ Text white
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ):item.statusId=="12"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                    "POSTPONED",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="13"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,   // ✅ Background green
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
                              ):item.statusId=="14"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,   // ✅ Background green
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
                              ):item.statusId=="15"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "PICKUP",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="16"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,   // ✅ Background green
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
                              ):item.statusId=="17"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,   // ✅ Background green
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
                              ):item.statusId=="18"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,   // ✅ Background green
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
                              ):item.statusId=="19"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "POSTPONED",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="20"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "PICKUP",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="21"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "POSTPONED",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="22"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrangeAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "RTO",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):item.statusId=="23"?Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,   // ✅ Background green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "PICKUP",
                                  style: TextStyle(
                                    color: Colors.white,   // ✅ Text white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):SizedBox.shrink()
                          ),
                          DataCell(Text(item.callCount ?? "-")),
                          DataCell(Text(item.ufor ?? "-")),
                          DataCell(Text(_formatDate(item.appDate ?? "-"))),
                          DataCell(Text(item.appTime ?? "-")),
                          DataCell(Text(item.appPin ?? "-")),
                          DataCell(Text(item.clientCode ?? "-")),
                          DataCell(Text(item.customerName ?? "-")),
                          DataCell(Text(item.remarks ?? "-")),
                          DataCell(Text(item.firstcall ?? "-") ),
                          DataCell(Text(item.lastcall ?? "-")),
                          DataCell(Text(item.callType ?? "-")),
                          DataCell(Text(item.dialCallStatus ?? "-")),
                          DataCell(Text(item.dialCallDuration ?? "-")),


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
        backgroundColor: Colors.amber,
        onPressed: exportToPdf,
        child: const Icon(Icons.download,color: Colors.black,),
      ),
    );
  }
}
