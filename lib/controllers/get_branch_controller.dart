import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/get_all_branch_model.dart';

class BranchController {
  final String apiUrl = "https://fms.bizipac.com/apinew/ws_new/get_all_branch.php";

  Future<List<GetAllBranchModel>> fetchBranches() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == 1) {
          List branches = jsonResponse['data'];
          return branches.map((e) => GetAllBranchModel.fromJson(e)).toList();
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      throw Exception('Error fetching branches: $e');
    }
  }
}
