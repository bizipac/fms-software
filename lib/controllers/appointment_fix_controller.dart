import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

Future<void> sendFixAppointment(
     String userid,
    String appDate,
    String appTime,
    String appLoc,
    List<String> appDoc,
    String feName,
    Map<String, dynamic> appData
    ) async {

  final url = Uri.parse(
      "https://fms.bizipac.com/apinew/action/appfix.php?teleid=$userid");

  final Map<String, dynamic> body = {
    "appdate": appDate,        // ← your selected date
    "apptime": appTime,        // ← your selected time
    "apploc": appLoc,          // ← your selected location
    "appdoc": appDoc,          // ← selected documents list
    "appwithfe": true,
    "appfeid": feName,         // ← FE name / ID from parameter
    "appdata": appData         // ← Whole appData map from parameter
  };
  print("-------------------");
  print(body);
  print("----------------------");
  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    print("---------------");
    print(response);

    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");



  } catch (e) {
    print("Error: $e");
  }
}
