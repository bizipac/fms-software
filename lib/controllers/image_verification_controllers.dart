import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_verification_model.dart';

class ImageVerificationService {
  Future<Imageverification?> fetchImageVerification({
    required String clientId,
    required String fromDate,
    required String toDate,
    required String feaction,
  }) async {
    final url = Uri.parse(
        'https://fms.bizipac.com/apinew/display/civ.php');

    final Map<String, dynamic> body = {
      "client_id": clientId,
      "lead_from": fromDate,
      "lead_to": toDate,
      "search": feaction,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("---------Response Body---------");
      print(response.body);
      print("------------------");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        return Imageverification.fromJson(jsonResponse);
      } else {
        print("Error: Status Code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception Error: $e");
      return null;
    }
  }
}
