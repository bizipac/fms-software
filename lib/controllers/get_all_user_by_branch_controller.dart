import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_by_branch_model.dart';


class UserService {
  //https://fms.bizipac.com/apinew/ws_new/get_users_by_branch.php?branch_id="26"
  static const String _baseUrl =
      "https://fms.bizipac.com/apinew/ws_new/get_users_by_branch.php";

  static Future<List<UserByBranchModel>> getUsersByBranch(String branchId) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: {"branch_id": branchId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        final List users = data['data'];
        return users.map((e) => UserByBranchModel.fromJson(e)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Failed to load users (${response.statusCode})");
    }
  }
}
