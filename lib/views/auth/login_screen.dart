import 'package:flutter/material.dart';
import 'package:fms_software/utils/app_constant.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/user_login_controller.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final loginController = Get.put(UserLoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // for responsiveness

    return Scaffold(
      backgroundColor: Colors.white,
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
                  // 🔹 Logo at the top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/logo/cmp_logo.png', // ← your logo path
                      height: size.height * 0.08,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // 🔹 Title text
                  const Text(
                    'Hi !',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Welcome to Bizipac',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "I'm waiting for you, please enter your detail",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),
                  // 🔹 Mobile number field
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      } else if (value.length < 10) {
                        return 'Enter valid mobile number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Register mobile number',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: const OutlineInputBorder(),
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
                  SizedBox(height: size.height * 0.03),
                  // 🔹 Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: const OutlineInputBorder(),
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.07),
                  // 🔹 Login button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  AppConstant.appBarColor, // yellow button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginController.loginUser(_mobileController.text, _passwordController.text);
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
