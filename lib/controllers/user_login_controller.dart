import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fms_software/models/user_model.dart';
import 'package:fms_software/views/auth/otp_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/app_constant.dart';



class UserLoginController extends GetxController {
  var isLoading = false.obs;
  var loginResponse = Rxn<UserModel>();


  Future<void> loginUser(String mobile, String password) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse(
          'https://fms.bizipac.com/apinew/peak_me_admin/user_login.php?mobile=$mobile&password=$password');


      final response = await http.get(uri);


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        loginResponse.value = UserModel.fromJson(data);
        if (loginResponse.value!.success == 1) {
          UserModel data=UserModel(success: loginResponse.value!.success, message: loginResponse.value!.message, data: loginResponse.value!.data);
          Get.to(()=>OtpScreen(userModel: data));
        } else {
          Get.snackbar(
            "Error",
            loginResponse.value!.message,
            icon: Image.asset(
              "assets/logo/cmp_logo.png",
              height: 30,
              width: 30,
            ),
            shouldIconPulse: true,
            // Small animation on the icon
            backgroundColor: AppConstant.whiteBackColor,
            colorText: AppConstant.appTextColor,
            snackPosition: SnackPosition.TOP,
            // or TOP
            borderRadius: 15,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 3),
            isDismissible: true,
            forwardAnimationCurve: Curves.easeOutBack,
          );
        }
      } else {

        Get.snackbar(
          'Error', 'Server error: ${response.statusCode}',
          icon: Image.asset(
            "assets/logo/cmp_logo.png",
            height: 30,
            width: 30,
          ),
          shouldIconPulse: true,
          // Small animation on the icon
          backgroundColor: AppConstant.whiteBackColor,
          colorText: AppConstant.appTextColor,
          snackPosition: SnackPosition.TOP,
          // or TOP
          borderRadius: 15,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}