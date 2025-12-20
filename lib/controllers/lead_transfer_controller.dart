import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_transfer_model.dart';

class LeadTransferService {
  static const String apiUrl =
      "https://fms.bizipac.com/apinew/display/leadtransfer.php";

  Future<LeadTransferResponse?> fetchLead(String branch, String mobile) async {
    try {
      final body = jsonEncode({
        "branch": branch,
        "mobile": mobile,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        return LeadTransferResponse.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
