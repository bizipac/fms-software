import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/userlist_model.dart';

class UserController {
  // static const String apiUrl =
  //     "https://fms.bizipac.com/apinew/display/userlist.php?branch=$branchid&type=6";

  Future<List<UserData1>> fetchUsers(String branchid) async {
    final url = Uri.parse("https://fms.bizipac.com/apinew/display/userlist.php?branch=$branchid&type=6");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List users = jsonData['userlist'];
      print("---------------------");
      print(users);
      return users.map((e) => UserData1.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch users");
    }
  }
}
