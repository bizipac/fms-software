import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/get_lead_details_model.dart';

class LeadService {
  static const String baseUrl = "https://fms.bizipac.com/apinew/peak_me_admin/getLeadDetails.php?";

  static Future<GetLeadDetails?> fetchLeads(String mobileOrLeadId) async {
    try {
      final url = Uri.parse(baseUrl);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobile": mobileOrLeadId}),
      );

      print("📤 Sending: ${jsonEncode({"mobile": mobileOrLeadId})}");
      print("📦 Response code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📨 Response body: $data");

        if (data['status'] == 'ok') {
          return GetLeadDetails.fromJson(data);
        } else {
          print("⚠️ No leads found: ${data['message']}");
          return null;
        }
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching leads: $e");
      return null;
    }
  }
}
