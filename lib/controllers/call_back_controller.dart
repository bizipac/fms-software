import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/call_back_model.dart';

class CallLaterService {


  Future<CallLaterResponse> fetchCallLaterLeads({
    required String dfrom,
    required String branch,
    required String client,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse("https://fms.bizipac.com/apinew/display/call_later.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "dfrom": dfrom,
          "branch": branch,
          "client": client,
        }),
      )
          .timeout(const Duration(seconds: 20));

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return CallLaterResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Server error ${response.statusCode}");
      }
    } catch (e) {
      print("API ERROR: $e");
      rethrow;
    }
  }

}
