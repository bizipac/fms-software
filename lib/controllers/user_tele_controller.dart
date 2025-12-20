import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_tele_response_model.dart';

class UserListController {
  Future<List<UserTeleModel>> fetchUsers(String branch, String type) async {
    final url = Uri.parse(
        "https://fms.bizipac.com/apinew/display/userlist.php?branch=$branch&type=$type");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = UserTeleResponse.fromJson(body);
      return data.userlist;
    } else {
      throw Exception("Failed to load users");
    }
  }
}
