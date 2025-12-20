import 'dart:convert';
import 'package:http/http.dart' as http;

class LeadTransferBranchService {
  Future<bool> transferLead({
    required String userId,
    required List<Map<String, dynamic>> leadList,
    required String branchId,
  }) async {
    final url =
        "https://fms.bizipac.com/apinew/action/leadTransferBranch.php?user_id=$userId";

    try {
      final body = jsonEncode({
        "lead": leadList,
        "config": {"branchid": branchId}
      });

      print("----------- API REQUEST BODY -----------");
      print(body);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: body,
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["status"].toString() == "1";
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
