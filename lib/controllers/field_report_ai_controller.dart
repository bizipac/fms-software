import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/field_report_ai_model.dart';

class FieldReportAiController {
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<FieldExecutive>> reports = ValueNotifier([]);

  Future<FieldReportAiModel?> fetchReports({
    required List<String> branchIds,
    required String client,
    required String repDate,
    required String repDate1,
  }) async {
    try {
      isLoading.value = true;

      const url =
          'https://fms.bizipac.com/apinew/peak_me_admin/fieldreport_ai.php';

      final body = {
        "branch_id": branchIds,
        "client": client,
        "rep_date": repDate,
        "rep_date1": repDate1,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = FieldReportAiModel.fromJson(jsonData);

        reports.value = model.fieldexecutive;

        return model;   // ✅ RETURN MODEL
      } else {
        reports.value = [];
        return null;
      }
    } catch (e) {
      print('Error: $e');
      reports.value = [];
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
