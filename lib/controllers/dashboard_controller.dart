import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';

class DashboardController {
  Future<DashboardResponse?> fetchDashboard(String branchId) async {
    print("-------------");
    print(branchId);
    try {
      final response = await http.get(
        Uri.parse(
          "https://fms.bizipac.com/apinew/display/mob_health_dashboard.php?branch_id=$branchId",
        ),
      );
      print("---------------------");
      print(response);
      final jsonData = jsonDecode(response.body);
      print("---------------------------------");
      print("---------------json------------------");
      print(jsonData);
      print("---------------------------------");
      print("---------------------------------");
      if (jsonData['status'] == 'ok') {
        return DashboardResponse.fromJson(jsonData);
      }
    } catch (e) {
      print("Dashboard API Error: $e");
    }
    return null;
  }
}
