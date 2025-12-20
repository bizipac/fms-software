import 'dart:convert';
import 'package:http/http.dart' as http;

class AssignToFeController {
  Future<Map<String, dynamic>> assignLead({
    required List<Map<String, dynamic>> leads,
    required Map<String, dynamic> config,
    required String userid,
  }) async {
    final url = Uri.parse(
      "https://fms.bizipac.com/apinew/action/assigntofe.php?user_id=$userid",
    );

    final payload = {
      "lead": leads,
      "config": config,
    };

    try {
      print("===== API REQUEST START =====");
      print("URL: $url");
      print("Payload: ${jsonEncode(payload)}");
      print("==============================");

      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print("===== API RESPONSE =====");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      print("========================");

      // JSON parse safe block
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (err) {
        decoded = {"error": "Invalid JSON response", "raw": response.body};
      }

      return {
        "statusCode": response.statusCode,
        "body": decoded,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"error": e.toString()},
      };
    }
  }
}
