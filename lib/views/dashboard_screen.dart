import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fms_software/views/auth/login_screen.dart';
import 'package:fms_software/views/ci_verification_screen.dart';
import 'package:fms_software/views/cia_verification_screen.dart';
import 'package:fms_software/views/profile_screen.dart';
import 'package:fms_software/views/query_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notification/send_notification_screen.dart';
import '../services/get_server_key.dart';
import '../utils/app_constant.dart';


class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _currentTime = DateTime.now();
  late Timer _timer;
  int? userId;
  int? userRole;
  int? authId;
  int? branchId;

  String? userName;
  String? branchName;
  String? userFname;
  String? userAvatar;
  String? userAddress;
  String? branchMulti;
  String? userMobile;
  String? roleName;
  String? companyName;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    loadUserData(); // load on start
  }
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Read integers (may return null if not present)
    setState(() {
      userId     = prefs.getInt('user_id');       // e.g. 0 or null
      userRole   = prefs.getInt('user_role');
      authId     = prefs.getInt('auth_id');
      branchId   = prefs.getInt('branch_id');

      // Read strings (may return null)
      userName    = prefs.getString('user_name');
      branchName  = prefs.getString('branch_name');
      userFname   = prefs.getString('user_fname');
      userAvatar  = prefs.getString('user_avatar');
      userAddress = prefs.getString('user_address');
      branchMulti = prefs.getString('branch_multi');
      userMobile  = prefs.getString('user_mobile');
      roleName    = prefs.getString('role_name');
      companyName = prefs.getString('company_name');
    });
  }
  @override
  void dispose() {
    _timer?.cancel(); // stop before widget is destroyed
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final String timeString =
        '${_currentTime.hour.toString().padLeft(2, '0')}:'
        '${_currentTime.minute.toString().padLeft(2, '0')}:'
        '${_currentTime.second.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: AppConstant.appBarColor,
        title: Text(
          "${userAddress} - ${userFname}",
          style: TextStyle(color: AppConstant.appBarWhiteColor,fontSize: 15),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => ProfileScreen());
            },
            icon: Icon(Icons.person_pin, color: AppConstant.appBarWhiteColor),
          ),
          IconButton(onPressed: ()async{
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Get.offAll(() => const LoginScreen());
          }, icon: Icon(Icons.logout,color: Colors.white,))
        ],
      ),
      // drawer: AdminDrawerWidget(),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white24,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => CiVerificationScreen());
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "CI Verification",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppConstant.darkHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          Get.to(() => CiaVerificationScreen());
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "CIA Verification",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppConstant.darkHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.to(
                                () => QueryScreen(),
                          );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.query_stats,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Query Screen",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppConstant.darkHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          // _launchInBrowser(
                          //   'https://fms.bizipac.com/apinew/dynamic_form/executive_add_form.php?user_id=$uid#!/',
                          // );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_ind,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: [
                                      Text(
                                        "Lead Allocation",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppConstant.darkHeadingColor,
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Get.to(
                          //       () => LeadCheckScreen(uid: uid, branchId: branchId),
                          // );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.transfer_within_a_station,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Lead Transfer \nManger",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppConstant.darkHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          // _launchInBrowser(
                          //   'https://fms.bizipac.com/apinew/dynamic_form/executive_add_form.php?user_id=$uid#!/',
                          // );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.transfer_within_a_station_rounded,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: [
                                      Text(
                                        "Transfer View",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppConstant.darkHeadingColor,
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Get.to(
                          //       () => LeadCheckScreen(uid: uid, branchId: branchId),
                          // );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.dashboard_customize,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Lead Dashboard",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppConstant.darkHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          // _launchInBrowser(
                          //   'https://fms.bizipac.com/apinew/dynamic_form/executive_add_form.php?user_id=$uid#!/',
                          // );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.report,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: [
                                      Text(
                                        "Field Report AI",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppConstant.darkHeadingColor,
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Get.to(
                          //       () => LeadCheckScreen(uid: uid, branchId: branchId),
                          // );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.call_end_rounded,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Lead Asign \n to TL",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppConstant.darkHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 125,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppConstant.whiteBackColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppConstant.borderColor,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async{
                          // 1️⃣ Fetch server key first
                          GetServerKey getServerKey = GetServerKey();
                          String? serverKey = await getServerKey
                              .getServerKeyToken();
                          print("----------------------");
                          print(serverKey);
                          print("------------------------");
                          // 3️⃣ Navigate only if password correct
                            Get.to(
                                  () => SendMessageScreen(serverKeys: serverKey),
                            );
                        },
                        child: Stack(
                          children: [
                            // Inner shadow overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.16),
                                      // inner shadow feel
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Send Notification",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppConstant.darkHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 👇 Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Current Time : ".toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(Icons.access_time, size: 10, color: AppConstant.iconColor),
              ],
            ),

            // 👇 Version Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Version : ",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  AppConstant.appVersion,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: AppConstant.appIconColor,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.verified_outlined,
                  size: 10,
                  color: AppConstant.iconColor,
                ),
              ],
            ),

            // 👇 Copyright Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Copyrights © 2025 All Rights Reserved by - ",
                          maxLines: 2,
                          style: TextStyle(fontSize: 9),
                        ),
                        Text(
                          "Bizipac Couriers Pvt. Ltd.",
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppConstant.darkButton,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 👇 Postpone Lead Button
          ],
        ),
      ),
    );
  }
}