import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchLeadCallHistory(String leadId) async {
  const apiUrl = "https://fms.bizipac.com/apinew/peak_me_admin/lead_fe_calls.php?";

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"lead_id": int.parse(leadId)}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data["status"] == "ok" && data["lead_history"] != null) {
      return List<Map<String, dynamic>>.from(data["lead_history"]);
    } else {
      return [];
    }
  } else {
    throw Exception("Failed to fetch call history");
  }
}
