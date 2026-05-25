import 'package:flutter/material.dart';
import '../utils/app_constant.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: TextStyle(color: AppConstant.appBarWhiteColor, fontSize: 18),
        ),
        backgroundColor: AppConstant.appBarColor,
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Title & Version
            Center(
              child: Column(
                children: [
                  Text(
                    "CRM Peak Me Admin",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppConstant.appBarColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Version: ${AppConstant.appVersion}",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Welcome to CRM Peak Me Admin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "By using CRM Peak Me Admin, you agree to the following terms and conditions. "
              "Please read them carefully before using our services.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),

            Text(
              "1. Account Responsibility",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.",
            ),
            SizedBox(height: 10),

            Text(
              "2. Use of Service",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "You agree to use Peak Me only for lawful purposes and in accordance with all applicable laws. "
              "You may not misuse the app or attempt to gain unauthorized access to its systems.",
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),

            Text(
              "3. Admin Roles & Responsibilities",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "As an Admin user of CRM Peak Me Admin, you are responsible for managing users, leads, data access, "
                  "and operational activities within the system. You must ensure that all actions performed by you or "
                  "under your authority comply with company policies and applicable laws.",
            ),
            SizedBox(height: 10),

            Text(
              "4. User Management & Access Control",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Admins are authorized to create, modify, suspend, or delete user accounts. "
                  "You are responsible for assigning appropriate roles and permissions and ensuring that access "
                  "is granted only to authorized personnel.",
            ),
            SizedBox(height: 10),

            Text(
              "5. Data Accuracy & Integrity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Admins must ensure the accuracy, completeness, and integrity of customer, lead, and operational data. "
                  "Any intentional misuse, manipulation, or unauthorized sharing of data is strictly prohibited.",
            ),
            SizedBox(height: 10),

            Text(
              "6. Confidentiality & Security",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Admins must maintain strict confidentiality of sensitive business, customer, and system data. "
                  "Sharing login credentials, system access, or confidential information with unauthorized individuals "
                  "is a violation of these terms.",
            ),
            SizedBox(height: 10),

            Text(
              "7. Monitoring & Audit",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "All admin activities may be logged and monitored for security, compliance, and audit purposes. "
                  "Peak Me reserves the right to review admin actions in case of suspicious or unauthorized behavior.",
            ),
            SizedBox(height: 10),

            Text(
              "8. Admin Account Suspension",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Peak Me reserves the right to suspend or terminate admin access without prior notice if any "
                  "policy violation, misuse of privileges, or security risk is detected.",
            ),
            SizedBox(height: 10),

            SizedBox(height: 30),

            Divider(),
            Center(
              child: Column(
                children: [
                  Text(
                    "© 2025 Peak Me. All rights reserved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Company Name: Bizipac Couriers Pvt. Ltd.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Address: 337, Omkar Apartments, Shradhanand Road, Vile Parle East, Mumbai-400057, Maharashtra, India",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 2),

                  Text(
                    "Developed by: Shubham Gupta",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Email: info@teamunited.net",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 2),
                  SizedBox(height: 4),
                  Text(
                    "Authorized by Google as an Open App.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
