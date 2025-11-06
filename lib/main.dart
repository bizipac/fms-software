import 'package:flutter/material.dart';
import 'package:fms_software/views/auth/login_screen.dart';
import 'package:fms_software/views/dashboard_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_mobile');
    return uid != null && uid.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Peak Me FMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // show loader while checking
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            // logged in
            return DashboardScreen();
          } else {
            // not logged in
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
