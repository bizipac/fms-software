import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/daily_lead_report_model.dart';

class DailyLeadReportController extends GetxController {
  var isLoading = false.obs;
  var reportList = <DailyReportItem>[].obs;
  var leadCount = 0.obs;

  Future<void> fetchDailyReport({
    required String start,
    required String end,
    required String teleid,
    required String roleid,
  }) async {
    try {
      isLoading.value = true;

      final url =
          "https://fms.bizipac.com/apinew/report/dailyleadreport.php?start=$start&end=$end&teleid=$teleid&roleid=$roleid";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        leadCount.value = jsonData["leadCount"] ?? 0;

        reportList.value = (jsonData["report"] as List)
            .map((e) => DailyReportItem.fromJson(e))
            .toList();
      } else {
        Get.snackbar("Error", "Failed to load report");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
