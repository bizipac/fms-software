import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../utils/app_constant.dart';
import '../dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class OtpScreen extends StatefulWidget {
  final UserModel userModel;

  const OtpScreen({super.key, required this.userModel});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 🔹 Function to save user data locally
  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = widget.userModel.data.first;

    // Integers
    await prefs.setInt('user_id', user.userId ?? 0);
    await prefs.setInt('user_role', user.userRole ?? 0);
    await prefs.setInt('branch_id', user.branchId ?? 0);

    // Strings
    await prefs.setString('user_fname', user.userFname ?? '');
    await prefs.setString('user_avter', user.avatar ?? '');
    await prefs.setString('user_address', user.userAddress ?? '');
    await prefs.setString('branch_multi', user.branchMulti ?? '');
    await prefs.setString('user_mobile', user.userMobile ?? '');
    await prefs.setString('branch_name', user.branchName ?? '');
    await prefs.setString('role_name', user.roleName ?? '');
    await prefs.setString('company_name', user.companyName ?? '');
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/logo/cmp_logo.png',
                      height: size.height * 0.09,
                    ),
                  ),
                  SizedBox(height: size.height * 0.1),

                  const Text(
                    'OTP!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        'Hello - ',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.userModel.data.first.userFname ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.07),

                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      return null;
                    },
                    decoration:  InputDecoration(
                      labelText: 'Enter OTP..',
                      labelStyle: TextStyle(color: Colors.black54),
                      border:  OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppConstant.borderColor,
                        ), // border when not focused
                      ),
                      focusedBorder:  OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppConstant.borderColor,
                          width: 2.0,
                        ), // border when focused
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.07),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstant.appBarColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {

                        if (_formKey.currentState!.validate()) {
                          // 🔹 Compare OTP properly
                          if (_otpController.text.trim() == '111111') {
                            // ✅ Save to SharedPreferences
                            await saveUserData();
                            // ✅ Navigate to Dashboard
                            Get.offAll(() => DashboardScreen());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your OTP is wrong. Please enter the correct OTP.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
