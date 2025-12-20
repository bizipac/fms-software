import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/transfer_lead_model.dart';

class LeadController extends GetxController {
  var isLoading = false.obs;
  var leads = <LeadMaster>[].obs;

  Future<void> fetchLead(String branch, String mobile) async {
    try {
      isLoading.value = true;

      final url =
          "https://fms.bizipac.com/apinew/display/leadquery.php?branch=$branch&mobile=$mobile";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final leadResponse = LeadResponse.fromJson(jsonData);

        leads.value = leadResponse.leadMaster;
      } else {
        leads.clear();
      }
    } catch (e) {
      print("Error: $e");
      leads.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
