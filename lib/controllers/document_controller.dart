import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/DocumentResponse.dart';

class DocumentController {
  static Future<DocumentResponse?> fetchDocument() async {
    final url = Uri.parse("https://fms.bizipac.com/apinew/display/document.php");

    try {
      final response = await http.get(url);
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        /// Entire object → DocumentResponse
        return DocumentResponse.fromJson(jsonData);
      } else {
        print("Server Error");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
