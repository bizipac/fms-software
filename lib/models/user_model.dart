class UserModel {
  final int success;
  final String message;
  final List<UserData> data;


  UserModel({required this.success, required this.message, required this.data});


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((e) => UserData.fromJson(e)).toList() ?? [],
    );
  }
}


class UserData {
  final int userId;
  final String userMobile;
  final String userFname;
  final String branchMulti;
  final String userAddress;
  final String avatar;
  final int userRole;
  final int userStatus;
  final int branchId;
  final String branchName;
  final String companyName;
  final String roleName;
  final dynamic clientAuthId;
  final dynamic clientId;


  UserData({
    required this.userId,
    required this.userMobile,
    required this.userFname,
    required this.branchMulti,
    required this.userAddress,
    required this.avatar,
    required this.userRole,
    required this.userStatus,
    required this.branchId,
    required this.branchName,
    required this.companyName,
    required this.roleName,
    this.clientAuthId,
    this.clientId,
  });


  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'] ?? 0,
      userMobile: json['user_mobile'].toString(),
      userFname: json['user_fname'] ?? '',
      branchMulti: json['branch_multi'] ?? '',
      userAddress: json['user_address'] ?? '',
      avatar: json['avatar'] ?? '',
      userRole: json['user_role'] ?? 0,
      userStatus: json['user_status'] ?? 0,
      branchId: json['branch_id'] ?? 0,
      branchName: json['branch_name'] ?? '',
      companyName: json['company_name'] ?? '',
      roleName: json['role_name'] ?? '',
      clientAuthId: json['client_auth_id'],
      clientId: json['client_id'],
    );
  }
}