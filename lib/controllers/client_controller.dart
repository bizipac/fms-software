import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';

class ClientService {
  Future<List<ClientModel>> fetchClients(int branchId) async {
    final url = Uri.parse(
        'https://fms.bizipac.com/apinew/peak_me_admin/client_master.php?branch=$branchId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      if (jsonBody['status'] == 'ok' && jsonBody['client'] != null) {
        final List data = jsonBody['client'];
        return data.map((e) => ClientModel.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response structure');
      }
    } else {
      throw Exception('Failed to fetch clients: ${response.statusCode}');
    }
  }
}
