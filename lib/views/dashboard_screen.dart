import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fms_software/views/auth/login_screen.dart';
import 'package:fms_software/views/ci_verification_screen.dart';
import 'package:fms_software/views/cfi_verification_screen.dart';
import 'package:fms_software/views/lead_allocation_screen.dart';
import 'package:fms_software/views/lead_asign_to_tl_screen.dart';
import 'package:fms_software/views/lead_transfer_manager_screen.dart';
import 'package:fms_software/views/profile_screen.dart';
import 'package:fms_software/views/query_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/get_branch_controller.dart';
import '../models/dashboard_model.dart';
import '../models/get_all_branch_model.dart';
import '../notification/send_notification_screen.dart';
import '../services/get_server_key.dart';
import '../utils/app_constant.dart';
import 'assign_call_back_screen.dart';
import 'daily_lead_report_screen.dart';
import 'field_report_ai_screen.dart';
import 'transfer_view_screen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool showFab = false;
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

  final BranchController _branchController = BranchController();

  List<GetAllBranchModel> _branchList = [];
  GetAllBranchModel? _selectedBranch;
  bool _isLoading = true;
  List<String> allowedBranchIds = [];
  bool _isLoadingBranches = true;
  final DashboardController controller = DashboardController();
  DashboardResponse? dashboardResponse;
  bool isLoading = false;
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
    loadBranches();
    // 🔹 Screen open hone ke baad sheet show karega
  }

  bool _dialogShown = false;

  Future<void> _loadDashboard() async {
    if (_dialogShown) return;

    setState(() => isLoading = true);

    dashboardResponse = await controller.fetchDashboard(branchId.toString());
    setState(() => isLoading = false);

    if (dashboardResponse != null && !_dialogShown) {
      _dialogShown = true;
      _showCenterDialog();
    }
  }

  void _showCenterDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final data = dashboardResponse!.dashboard;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Health Dashboard - ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppConstant.appBarColor,
                        ),
                      ),
                      Text(
                        "$branchName",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  const SizedBox(height: 16),

                  /// ================= TELECALLING TABLE =================
                  _tableTitle("Telecalling"),
                  Table(
                    border: TableBorder.all(color: AppConstant.borderColor),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      _tableRow("Pending", data.tcDashboard.pending.toString()),
                      _tableRow(
                        "Overdue",
                        data.tcDashboard.pendingOverdue.toString(),
                      ),
                      _tableRow(
                        "Tele Calling",
                        data.tcDashboard.telecalling.toString(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ================= ON FIELD TABLE =================
                  _tableTitle("On Field"),
                  Table(
                    border: TableBorder.all(color: AppConstant.borderColor),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      _tableRow(
                        "Before Today",
                        data.onFieldDashboard.pendingBeforeToday.toString(),
                      ),
                      _tableRow(
                        "Today",
                        data.onFieldDashboard.today.toString(),
                      ),
                      _tableRow(
                        "Future",
                        data.onFieldDashboard.future.toString(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ================= APP FIXED TABLE =================
                  _tableTitle("App Fixed"),
                  Table(
                    border: TableBorder.all(color: AppConstant.borderColor),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      _tableRow(
                        "Before Today",
                        data.appFixedDashboard.pendingBeforeToday.toString(),
                      ),
                      _tableRow(
                        "Today",
                        data.appFixedDashboard.today.toString(),
                      ),
                      _tableRow(
                        "Future",
                        data.appFixedDashboard.future.toString(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppConstant.appBarColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Dashboard",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void updateBranch(String newBranchId, String newBranchName) async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 Convert String to int correctly
    int newbranch_id = int.tryParse(newBranchId) ?? 0;

    // 🔥 Save updated values
    await prefs.setInt('branch_id', newbranch_id);
    await prefs.setString('branch_name', newBranchName);

    // 🔥 Read again to confirm
    int? savedId = prefs.getInt('branch_id');
    String? name = prefs.getString('branch_name');

    print("---------------------");
    print("Updated Branch Name: $name");
    print("Updated Branch ID  : $savedId");
    print("Branch updated successfully!");
    setState(() {});
  }

  Future<void> loadBranches() async {
    try {
      List<GetAllBranchModel> branches = await _branchController
          .fetchBranches();
      // API से पूरी branch list आती होगी
      List<GetAllBranchModel> allBranches = branches;

      // 🔥 Filter only branches that match branchMulti
      List<GetAllBranchModel> filtered = allBranches.where((b) {
        return allowedBranchIds.contains(b.branchId.toString());
      }).toList();
      setState(() {
        _branchList =
            filtered; // 🔥 अब dropdown में सिर्फ filtered branches आएंगी
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Read integers (may return null if not present)
    setState(() {
      userId = prefs.getInt('user_id'); // e.g. 0 or null
      userRole = prefs.getInt('user_role');
      authId = prefs.getInt('auth_id');
      branchId = prefs.getInt('branch_id');

      // Read strings (may return null)
      userName = prefs.getString('user_name');
      branchName = prefs.getString('branch_name');
      userFname = prefs.getString('user_fname');
      userAvatar = prefs.getString('user_avatar');
      userAddress = prefs.getString('user_address');
      branchMulti = prefs.getString('branch_multi');
      userMobile = prefs.getString('user_mobile');
      roleName = prefs.getString('role_name');
      companyName = prefs.getString('company_name');
      if (branchMulti != null && branchMulti!.isNotEmpty) {
        allowedBranchIds = branchMulti!.split(','); // ["1","5","8"]
      }
      setState(() {});
      // ✅ IMPORTANT: branchId milne ke baad hi dashboard call
      if (branchId != null) {
        _loadDashboard();
      }
    });
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    const apiKey = "c982fe4c7334887db95c4653c68a5fde"; // ← अपनी API key डालें

    // 1. Permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw "Location permission denied";
    }

    // 2. Current Location
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 3. Weather API Call
    final url =
        "https://api.openweathermap.org/data/3.0/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$apiKey&units=metric";
    print(url);

    final response = await http.get(Uri.parse(url));
    print("----------------");
    print(response.body);
    print("----------------");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw "Failed to load weather";
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // stop before widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    final String timeString =
        '${_currentTime.hour.toString().padLeft(2, '0')}:'
        '${_currentTime.minute.toString().padLeft(2, '0')}:'
        '${_currentTime.second.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: AppConstant.appBarColor,
        title: Column(
          children: [
            Text(
              "Name - ${userFname}",
              style: TextStyle(
                color: AppConstant.appBarWhiteColor,
                fontSize: 14,
              ),
            ),

            Text(
              "($branchName)",
              style: TextStyle(color: Colors.yellow, fontSize: 13),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.bottomSheet<GetAllBranchModel>(
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                DropdownButtonFormField<GetAllBranchModel>(
                                  value: _selectedBranch,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Select Branch",
                                  ),
                                  items: _branchList.map((branch) {
                                    return DropdownMenuItem(
                                      value: branch,
                                      child: Text(branch.branchName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedBranch = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_selectedBranch == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Please select a branch",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // 🔥 Update SharedPreferences
                                    updateBranch(
                                      _selectedBranch!.branchId.toString(),
                                      _selectedBranch!.branchName,
                                    );

                                    // 🔥 Close bottom sheet and return selected branch
                                    Get.back(result: _selectedBranch);
                                  },
                                  child: Text("Save"),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                isDismissible: true,
                enableDrag: true,
              ).then((value) {
                // 🔥 value = selected branch from bottom sheet
                if (value != null) {
                  setState(() {
                    _selectedBranch = value;
                    Get.offAll(() => DashboardScreen());
                  });

                  // Optional: Success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "You are entering the branch: ${_selectedBranch!.branchName.toString()}",
                      ),
                      duration: const Duration(seconds: 3), // 3-second duration
                    ),
                  );
                  setState(() {});
                }
              });
            },
            icon: Icon(Icons.settings, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Get.to(() => ProfileScreen());
            },
            icon: Icon(Icons.person_pin, color: AppConstant.appBarWhiteColor),
          ),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Get.offAll(() => const LoginScreen());
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      // drawer: AdminDrawerWidget(),
      //1500f272ad9d47a979e5142838dd0449
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white24,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                branchId == 1
                    ? Row(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.verified_user,
                                          size: 30,
                                          color: AppConstant.iconColor,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Image Verification",
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
                                Get.to(() => CfiVerificationScreen());
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.verified_user,
                                          size: 30,
                                          color: AppConstant.iconColor,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "FI Verification",
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
                      )
                    : SizedBox.shrink(),
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
                          Get.to(() => QueryScreen());
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
                          Get.to(
                            () => LeadAllocationScreen(branchid: "$branchId"),
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
                        onTap: () async {
                          Get.to(
                            () => LeadTransferManagerScreen(
                              branchid: branchId.toString(),
                            ),
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
                                    Icons.transfer_within_a_station,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Lead Transfer \n Management",
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
                          Get.to(() => TransferViewScreen());
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
                          Get.to(
                            () => DailyLeadReportScreen(
                              userid: userId.toString(),
                              roleid: userRole.toString(),
                            ),
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
                          Get.to(() => FieldReportAiScreen());
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
                          Get.to(
                            () => FreshLeadScreen(
                              user_id: userId.toString(),
                              branchid: branchId.toString(),
                            ),
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
                                    Icons.call_end_rounded,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Lead Assign \n to TL",
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
                        onTap: () {
                          Get.to(
                            () => AssignCallBackScreen(
                              branchid: branchId.toString(),
                              user_id: userId.toString(),
                            ),
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
                                    Icons.assignment_turned_in,
                                    size: 30,
                                    color: AppConstant.iconColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Assign Call Back",
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
                        onTap: () async {
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

  TableRow _tableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppConstant.appBarColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }

  Widget _tableTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppConstant.appBarColor,
          ),
        ),
      ),
    );
  }
}
