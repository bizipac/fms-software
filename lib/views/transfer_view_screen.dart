import 'package:flutter/material.dart';

import '../utils/app_constant.dart';

class TransferViewScreen extends StatefulWidget {
  const TransferViewScreen({super.key});

  @override
  State<TransferViewScreen> createState() => _TransferViewScreenState();
}

class _TransferViewScreenState extends State<TransferViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text(
          'Transfer View',
          style: TextStyle(color: AppConstant.appBarWhiteColor, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                   // controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Enter Mobile / Lead ID",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      )
    );
  }
}
