import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fresh_lead_model.dart';

class FreshLeadController {
  Future<AssignToTLModel?> fetchFreshLeads({
    required String branch,
    required String client,
  }) async {
    const url = "https://fms.bizipac.com/apinew/display/freshlead.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "branch": branch,
          "client": client,
        }),
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AssignToTLModel.fromJson(jsonData);
      }
    } catch (e) {
      print("Error fetching fresh leads: $e");
    }
    return null;
  }
}
