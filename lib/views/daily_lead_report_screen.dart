import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/daily_lead_controller.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../controllers/daily_lead_controller.dart';
import '../utils/app_constant.dart';

class DailyLeadReportScreen extends StatefulWidget {
  final String userid;
  final String roleid;

  const DailyLeadReportScreen({
    super.key,
    required this.userid,
    required this.roleid,
  });

  @override
  State<DailyLeadReportScreen> createState() => _DailyLeadReportScreenState();
}

class _DailyLeadReportScreenState extends State<DailyLeadReportScreen> {
  final controller = Get.put(DailyLeadReportController());

  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat _formatter = DateFormat('yyyy/MM/dd');

  @override
  void initState() {
    super.initState();
  }

  Future<void> _downloadExcel() async {
    if (controller.reportList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to download")),
      );
      return;
    }

    // Create Excel
    var excel = Excel.createExcel(); // <--- HERE
    Sheet sheetObject = excel["DailyLeadReport"];

    int parseInt(String? v) => int.tryParse(v ?? "") ?? 0;

    // Header
    sheetObject.appendRow([
      TextCellValue("Client"),
      TextCellValue("Fresh"),
      TextCellValue("App Fix"),
      TextCellValue("Telecaller"),
      TextCellValue("On Field"),
      TextCellValue("Error Received"),
      TextCellValue("Picked Up"),
      TextCellValue("RTO"),
      TextCellValue("RTO Duplicate"),
      TextCellValue("Submitted"),
      TextCellValue("Total"),
      TextCellValue("Pending"),
      TextCellValue("Submission %"),
    ]);

    // Data rows
    for (var item in controller.reportList) {
      sheetObject.appendRow([
        TextCellValue(item.client ?? ""),
        IntCellValue(parseInt(item.fresh)),
        IntCellValue(parseInt(item.appFix)),
        IntCellValue(parseInt(item.telecaller)),
        IntCellValue(parseInt(item.onField)),
        IntCellValue(parseInt(item.errorRec)),
        IntCellValue(parseInt(item.pickedup)),
        IntCellValue(parseInt(item.rto)),
        IntCellValue(parseInt(item.rtoDuplicate)),
        IntCellValue(parseInt(item.submitted)),
        IntCellValue(parseInt(item.total)),
        IntCellValue(item.pending ?? 0),
        IntCellValue(item.submissionPercentage ?? 0),
      ]);
    }

    // Permissions
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
      return;
    }

    // Set path
    Directory downloads = Directory("/storage/emulated/0/Download");
    if (!downloads.existsSync()) {
      downloads = await getExternalStorageDirectory() ?? downloads;
    }

    final folder = Directory("${downloads.path}/DailyReports");
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    final filePath =
        "${folder.path}/DailyLeadReport_${DateTime.now().millisecondsSinceEpoch}.xlsx";

    // SAVE FILE
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!); // <--- excel is visible here!

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Excel saved at: $filePath"),
        backgroundColor: Colors.green,
      ),
    );
  }



// Helper: request storage permission
  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _searchReport() {
    if (_startDate == null || _endDate == null) {
      Get.snackbar("Error", "Please select start and end dates");
      return;
    }

    controller.fetchDailyReport(
      start: _formatter.format(_startDate!),
      end: _formatter.format(_endDate!),
      teleid: widget.userid,
      roleid: widget.roleid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppConstant.appBarColor,
        title: const Text("Daily Lead Report",style: TextStyle(color: AppConstant.appStatusBarColor),),

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _startDate != null ? _formatter.format(_startDate!) : "Start Date",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _endDate != null ? _formatter.format(_endDate!) : "End Date",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchReport,
                  child: const Text("Search"),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.reportList.isEmpty) {
                return const Center(child: Text("No data found"));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _searchReport();
                },
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    const SizedBox(height: 12),
                    ...controller.reportList.map((item) => _buildReportCard(item)),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 60,),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _downloadExcel,child: Icon(Icons.file_download),),
    );
  }



  Widget _buildReportCard(item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,               // 🔥 full white background
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.client ?? "",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppConstant.appBarColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Divider(),  // 🔥 line under heading

                  _buildRow("Fresh", item.fresh),
                  _divider(),

                  _buildRow("App Fix", item.appFix),
                  _divider(),

                  _buildRow("Telecaller", item.telecaller),
                  _divider(),

                  _buildRow("On Field", item.onField),
                  _divider(),

                  _buildRow("Error Received", item.errorRec),
                  _divider(),

                  _buildRow("Picked Up", item.pickedup),
                  _divider(),

                  _buildRow("RTO", item.rto),
                  _divider(),

                  _buildRow("RTO Duplicate", item.rtoDuplicate),
                  _divider(),

                  _buildRow("Submitted", item.submitted),
                  _divider(),

                  _buildRow("Total", item.total),
                  _divider(),

                  _buildRow("Pending", item.pending.toString()),
                  _divider(),

                  _buildRow("Submission %", "${item.submissionPercentage}%"),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      color: Colors.black12,  // thin grey line
      height: 1,
    );
  }

}
