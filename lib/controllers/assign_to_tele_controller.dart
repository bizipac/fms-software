import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignToTeleController {
  Future<void> assignToTele({
    required BuildContext context,
    required List<Map<String, dynamic>> leads,
    required String teleId,
    required String userId,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    final url = Uri.parse(
      "https://fms.bizipac.com/apinew/action/assigntotele.php?teleid=$teleId&user_id=$userId",

    );

    try {
      onStartLoading();

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(leads),
      );

      onStopLoading();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✔ Success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(data["message"] ?? "Assigned Successfully!"),
          ),
        );
      } else {
        // ❌ API Failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content:
            Text("Failed! Server returned ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      onStopLoading();
      // ❌ Error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: $e"),
        ),
      );
    }
  }
}
