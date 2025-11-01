import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../services/get_server_key.dart';
import '../../utils/app_constant.dart';

class SendMessageScreen extends StatefulWidget {
  final String serverKeys;

  SendMessageScreen({super.key, required this.serverKeys});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: AppConstant.appBarColor,
        title: Text(
          "Send Message",
          style: TextStyle(color: AppConstant.whiteBackColor),
        ),
        iconTheme: IconThemeData(color: AppConstant.whiteBackColor),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Text("notification screen")
    );
  }
}
