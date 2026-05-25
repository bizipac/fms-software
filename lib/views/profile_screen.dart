import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/app_constant.dart';
import 'terms_conditions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? userId, authId, branchId;
  String? userFname,
      userAvatar,
      userAddress,
      userMobile,
      roleName,
      branchName,
      companyName;

  bool isLoading = true;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
      authId = prefs.getInt('auth_id');
      branchId = prefs.getInt('branch_id');
      userFname = prefs.getString('user_fname');
      userAvatar = prefs.getString('user_avatar');
      userAddress = prefs.getString('user_address');
      userMobile = prefs.getString('user_mobile');
      roleName = prefs.getString('role_name');
      branchName = prefs.getString('branch_name');
      companyName = prefs.getString('company_name');
      isLoading = false;
    });
  }

  void toggleCard() {
    setState(() {
      isFront = !isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade300,

      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 18,color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline,color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsAndConditionsScreen(),
                ),
              );
            },
          )
        ],

      ),
      body: Center(
        child: GestureDetector(
          onTap: toggleCard,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              final rotate =
              Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(rotate.value),
                    child: child,
                  );
                },
              );
            },
            child: isFront ? frontCard() : backCard(),
          ),
        ),
      ),
    );
  }

  // ================= FRONT CARD =================
  Widget frontCard() {
    return Container(
      key: const ValueKey("front"),
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black26,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // HEADER
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppConstant.darkButton,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Text(
                companyName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // PROFILE SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage:
                  (userAvatar != null && userAvatar!.startsWith('http'))
                      ? NetworkImage(userAvatar!)
                      : const AssetImage('assets/logo/cmp_logo.png')
                  as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userFname ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        roleName?.toUpperCase() ?? '',
                        style: TextStyle(
                          color: AppConstant.darkButton,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("ID : $userId",
                          style: const TextStyle(fontSize: 11)),
                      Text("Branch : $branchName",
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                )
              ],
            ),
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              "Tap to flip",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BACK CARD =================
  Widget backCard() {
    return Container(
      key: const ValueKey("back"),
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black26,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: "USER_ID:$userId | AUTH_ID:$authId",
            size: 90,
          ),
          const SizedBox(height: 10),
          Text(
            "Mobile : ${userMobile ?? ''}",
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              userAddress ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Authorized Personnel",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
