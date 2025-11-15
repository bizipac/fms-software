import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/FiVerificationList_model.dart';

class FiVerificationService {
  Future<List<FiClientItem>?> fetchVerificationClients({
    required String clientId,
    required String fromDate,
    required String toDate,
    required String feaction,
    required String typeId,
    required String branchId,
  }) async {
    final url = Uri.parse('https://fms.bizipac.com/apinew/peak_me_admin/fi_verification_list_new.php');

    final Map<String, dynamic> body = {
      "clientid": clientId,
      "leadfrom_date": fromDate,
      "leadto_date": toDate,
      "feaction": feaction,
      "type_id": typeId,
      "branch_id": branchId,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("---------Response Body---------");
    print(response.body);
    print("------------------");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Check if response is empty or malformed
      if (jsonData == null || jsonData is! Map<String, dynamic>) {
        throw Exception("Invalid JSON structure from API");
      }

      final fiList = FiVerificationList.fromJson(jsonData);
      if (fiList.status != 'ok') {
        throw Exception('API status not okay: ${fiList.status}');
      }
      if (fiList.client.isEmpty) {
        print("⚠️ Client array empty in response.");
        return [];
      }

      // flatten if nested
      return fiList.client;
    } else {
      throw Exception('Failed to load client list: HTTP ${response.statusCode}');
    }
  }
}
