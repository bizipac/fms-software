import 'package:flutter/material.dart';

import '../utils/app_constant.dart';

class CiVerificationScreen extends StatefulWidget {
  const CiVerificationScreen({super.key});

  @override
  State<CiVerificationScreen> createState() => _CiVerificationScreenState();
}

class _CiVerificationScreenState extends State<CiVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CI Verification",style: TextStyle(color: AppConstant.appBarWhiteColor),),
        backgroundColor: AppConstant.appBarColor,
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
    );
  }
}
