import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constant.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? userId, userRole, authId, branchId;
  String? userName,
      branchName,
      userFname,
      userAvatar,
      userAddress,
      branchMulti,
      userMobile,
      roleName,
      companyName;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getInt('user_id');
      userRole = prefs.getInt('user_role');
      authId = prefs.getInt('auth_id');
      branchId = prefs.getInt('branch_id');

      userName = prefs.getString('user_name');
      branchName = prefs.getString('branch_name');
      userFname = prefs.getString('user_fname');
      userAvatar = prefs.getString('user_avatar');
      userAddress = prefs.getString('user_address');
      branchMulti = prefs.getString('branch_multi');
      userMobile = prefs.getString('user_mobile');
      roleName = prefs.getString('role_name');
      companyName = prefs.getString('company_name');

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || companyName == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text(
          'Profile',
          style: TextStyle(color: AppConstant.appBarWhiteColor, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 6,
          child: Container(
            width: 300,
            height: 550,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppConstant.borderColor, width: 2),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔶 Header
                Container(
                  width: double.infinity,
                  color: AppConstant.darkButton,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          companyName ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 👤 Profile Image
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConstant.borderColor, width: 2),
                    ),
                    child: ClipOval(
                      child: Image(
                        image: (userAvatar != null && userAvatar!.startsWith('http'))
                            ? NetworkImage(userAvatar!)
                            : const AssetImage('assets/logo/cmp_logo.png') as ImageProvider,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                )
,
                const SizedBox(height: 20),
                // 🧾 Info Table
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Table(
                    border: TableBorder.all(
                      color: AppConstant.borderColor,
                      width: 1,
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      tableRow("Name", userFname ?? ''),
                      tableRow("User ID", "$userId"),
                      tableRow("Role", roleName?.toUpperCase() ?? ''),
                      tableRow("Mobile No.", userMobile ?? ''),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    children: [
                      const Divider(thickness: 1),
                      const SizedBox(height: 8),
                      Text(
                        userAddress ?? 'No address available',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 60,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Column(
                      //   children: [
                      //     Image.network(
                      //       'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBffILJ92k1DqB9SbQ2hSlGx3DCu22vNoGBA&s',
                      //       width: 80,
                      //       height: 40,
                      //       fit: BoxFit.contain,
                      //     ),
                      //
                      //   ],
                      // ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/logo/cmp_logo.png',
                            width: 80,
                            height: 40,
                            fit: BoxFit.contain,
                          ),

                        ],
                      ),
                      // Column(
                      //   children: [
                      //     Image.network(
                      //       'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpuLVmHdeBlG7ibYOp-61BhNjvy4RZvLwljA&s',
                      //       width: 80,
                      //       height: 40,
                      //       fit: BoxFit.contain,
                      //     ),
                      //
                      //   ],
                      // ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow tableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstant.darkButton,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
