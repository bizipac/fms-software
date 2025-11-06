import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fms_software/views/dashboard_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import '../controllers/get_all_user_by_branch_controller.dart';
import '../controllers/get_branch_controller.dart';
import '../../utils/app_constant.dart';
import '../models/get_all_branch_model.dart';
import '../models/user_by_branch_model.dart';
import '../services/get_server_key.dart';

class SendMessageScreen extends StatefulWidget {
  final String serverKeys;
  const SendMessageScreen({super.key, required this.serverKeys});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final BranchController _branchController = BranchController();
  List<GetAllBranchModel> _branchList = [];
  GetAllBranchModel? _selectedBranch;

  bool _isLoadingBranches = true;
  bool _isLoadingUsers = false;
  bool _isSending = false;

  List<UserByBranchModel> _userList = [];
  List<UserByBranchModel> _selectedUsers = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  /// 🔹 Fetch all branches
  Future<void> _loadBranches() async {
    try {
      final branches = await _branchController.fetchBranches();
      setState(() {
        _branchList = branches;
        _isLoadingBranches = false;
      });
    } catch (e) {
      setState(() => _isLoadingBranches = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading branches: $e')),
      );
    }
  }

  /// 🔹 Fetch all users by branch
  Future<void> _fetchUsers(String branchId) async {
    setState(() {
      _isLoadingUsers = true;
      _userList = [];
      _selectedUsers.clear();
    });

    try {
      final users = await UserService.getUsersByBranch(branchId);
      setState(() {
        _userList = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    } finally {
      setState(() => _isLoadingUsers = false);
    }
  }

  /// 🔹 Select all users
  void _toggleSelectAll() {
    setState(() {
      _selectedUsers = List.from(
        _userList.where((u) => u.userToken != null && u.userToken!.isNotEmpty),
      );
    });
  }

  /// 🔹 Clear all selections
  void _clearSelection() {
    setState(() {
      _selectedUsers.clear();
      _titleController.clear();
      _bodyController.clear();
    });
  }

  /// 🔹 Handle checkbox selection
  void _onUserSelected(bool? value, UserByBranchModel user) {
    if (user.userToken == null || user.userToken!.isEmpty) return;

    setState(() {
      if (value == true) {
        _selectedUsers.add(user);
      } else {
        _selectedUsers.removeWhere((u) => u.userToken == user.userToken);
      }
    });
  }

  Future<void> sendFcmMessageWithOAuth(
      String token,
      String title,
      String body,
      String? link,
      ) async {
    try {
      GetServerKey getServerKey = GetServerKey();
      String? serverKey = await getServerKey.getServerKeyToken();

      final response = await http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/bizipac-6bb00/messages:send"),
        headers: {
          "Authorization": "Bearer $serverKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "message": {
            "token": token,
            "notification": {
              "title": title,
              "body": body,
            },
            "data": {
              "url": link ?? "", // ✅ send the link here
            }
          },
        }),
      );

      print("✅ FCM Response (${token.substring(0, 10)}...): ${response.body}");
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }


  /// 🔹 Store notification details in database
  Future<void> storeNotificationInDB({
    required String title,
    required String body,
    required String userId,
    required String branchId,
    required String userFname,
    required String websiteURL,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("https://fms.bizipac.com/apinew/ws_new/insert_notification.php"),
        body: {
          "title": title,
          "body": body,
          "user_id": userId,
          "branch_id": branchId,
          "user_fname": userFname,
          "url": websiteURL,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();

        if (responseBody.isEmpty) {
          debugPrint("⚠️ Empty response from insert_notification.php");
          return;
        }

        // ✅ Safe to decode now
        final decoded = jsonDecode(responseBody);

        if (decoded['success'] == 1) {
          debugPrint("✅ Notification saved for $userFname");
        } else {
          debugPrint("❌ Failed to save notification: ${decoded['message']}");
        }
      } else {
        debugPrint("❌ Server error: ${response.statusCode}");
      }
    } catch (e, st) {
      debugPrint("❌ storeNotificationInDB Exception: $e\n$st");
    }
  }


  /// 🔹 Send to all selected users
  Future<void> _sendToSelectedUsers() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and body')),
      );
      return;
    }

    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users selected')),
      );
      return;
    }

    setState(() => _isSending = true);

    for (var user in _selectedUsers) {
      final token = user.userToken ?? '';
      await sendFcmMessageWithOAuth(
        token,
        _titleController.text.trim(),
        _bodyController.text.trim(),
        _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
      );

      print("---------------------------------");
      print(token);
      print(_titleController.text.toLowerCase());
      print(_bodyController.text.toLowerCase());
      print(user.userId.toString());
      print(_selectedBranch?.branchId.toString() ?? '');
      print(user.userName);
      print("Link: ${_linkController.text}");
      print("--------------------------------");

      await storeNotificationInDB(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        userId: user.userId.toString(),
        branchId: _selectedBranch?.branchId.toString() ?? '',
        userFname: user.userName,
        websiteURL: _linkController.text,
      );

      await Future.delayed(const Duration(milliseconds: 300));
    }


    setState(() => _isSending = false);
    Get.offAll(()=>DashboardScreen());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
        Text('✅ Notification sent to ${_selectedUsers.length} users'),
      ),
    );
    _clearSelection();
  }
  /// 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Send Notification",style: TextStyle(color: AppConstant.appBarWhiteColor),),
        backgroundColor: AppConstant.appBarColor,
        iconTheme: IconThemeData(color: AppConstant.appBarWhiteColor),
      ),
      body: _isLoadingBranches
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Branch Dropdown
              // DropdownButtonFormField<GetAllBranchModel>(
              //   decoration: const InputDecoration(
              //     labelText: "Select Branch",
              //     border: OutlineInputBorder(),
              //   ),
              //   value: _selectedBranch,
              //   items: _branchList.map((branch) {
              //     return DropdownMenuItem(
              //       value: branch,
              //       child: Text(branch.branchName),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() => _selectedBranch = value);
              //     if (value != null) {
              //       _fetchUsers(value.branchId.toString());
              //     }
              //   },
              // ),
              GestureDetector(
                onTap: () async {
                  final selected = await showDialog<GetAllBranchModel>(
                    context: context,
                    builder: (context) {
                      TextEditingController searchController = TextEditingController();
                      List<GetAllBranchModel> filteredList = List.from(_branchList);

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text("Select Branch"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    hintText: "Search branch...",
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      filteredList = _branchList
                                          .where((b) => b.branchName
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                          .toList();
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 250,
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final branch = filteredList[index];
                                      return ListTile(
                                        title: Text(branch.branchName),
                                        onTap: () {
                                          Navigator.pop(context, branch);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );

                  // ✅ Handle selection
                  if (selected != null) {
                    setState(() => _selectedBranch = selected);
                    _fetchUsers(selected.branchId.toString());
                  }
                },
                child: AbsorbPointer(
                  child: DropdownButtonFormField<GetAllBranchModel>(
                    value: _selectedBranch,
                    decoration: const InputDecoration(
                      labelText: "Select Branch",
                      border: OutlineInputBorder(),
                    ),
                    items: _branchList.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch.branchName),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
              )
,

              const SizedBox(height: 10),

              if (_userList.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleSelectAll,
                      icon: const Icon(Icons.select_all,color: Colors.white,),
                      label: const Text("Select All",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _clearSelection,
                      icon: const Icon(Icons.clear,color: Colors.white,),
                      label: const Text("Clear",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              _isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : _userList.isEmpty
                  ? const Center(
                child: Text("No users found for this branch"),
              )
                  : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _userList.length,
                itemBuilder: (context, index) {
                  final user = _userList[index];
                  final isSelected = _selectedUsers.any(
                          (u) => u.userToken == user.userToken);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.grey.shade400),
                    ),
                    child: ListTile(
                      title: Text(
                        user.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                          "User ID: ${user.userId ?? 'N/A'}"),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (value) =>
                            _onUserSelected(value, user),
                      ),
                    ),
                  );
                },
              ),

              /// Notification Form
              if (_selectedUsers.isNotEmpty) ...[
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                Text(
                  "Send Notification",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstant.appBarColor,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Body",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _linkController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    labelText: "link",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                    _isSending ? null : _sendToSelectedUsers,
                    icon: const Icon(Icons.send,color: Colors.white,),
                    label: Text(_isSending
                        ? "Sending..."
                        : "Send Notification",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstant.appBarColor,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
