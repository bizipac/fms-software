import 'package:flutter/material.dart';

import '../utils/app_constant.dart';

class CiaVerificationScreen extends StatefulWidget {
  const CiaVerificationScreen({super.key});

  @override
  State<CiaVerificationScreen> createState() => _CiaVerificationScreenState();
}

class _CiaVerificationScreenState extends State<CiaVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CIA Verification",style: TextStyle(color: AppConstant.appBarWhiteColor),),
      backgroundColor: AppConstant.appBarColor,
      iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
