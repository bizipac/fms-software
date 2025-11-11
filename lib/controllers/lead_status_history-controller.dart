import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/lead_status-history_model.dart';

class LeadHistoryController extends GetxController {
  var isLoading = false.obs;
  var historyList = <CrmRecord>[].obs;

  Future<void> fetchLeadHistory(String leadId) async {
    try {
      isLoading.value = true;
      final url = Uri.parse(
          'https://fms.bizipac.com/apinew/peak_me_admin/leadstatushistory.php?lead_id=$leadId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final model = LeadHistoryResponse.fromJson(data);
          historyList.value = model.crm;
        } else {
          Get.snackbar('Error', data['message'] ?? 'Invalid response');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Exception', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
