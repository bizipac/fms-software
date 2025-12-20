import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/appfixed_model.dart';

class AppFixedController {
  Future<List<AppFixedModel>> fetchAppFixed({
    required String branch,
    required String userid,
    required String client,
  }) async {
    final url = Uri.parse("https://fms.bizipac.com/apinew/display/appfixed.php");

    final body = {
      "branch": branch,
      "userid": userid,
      "client": client,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == "ok") {
        final List list = data["appfixed"];
        return list.map((e) => AppFixedModel.fromJson(e)).toList();
      } else {
        throw Exception("API Status not ok");
      }
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  }
}
