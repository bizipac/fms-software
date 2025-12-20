class UserTeleResponse {
  final String status;
  final int userCount;
  final List<UserTeleModel> userlist;

  UserTeleResponse({
    required this.status,
    required this.userCount,
    required this.userlist,
  });

  factory UserTeleResponse.fromJson(Map<String, dynamic> json) {
    return UserTeleResponse(
      status: json["status"],
      userCount: json["userCount"],
      userlist: List<UserTeleModel>.from(
        json["userlist"].map((x) => UserTeleModel.fromJson(x)),
      ),
    );
  }
}

class UserTeleModel {
  final String userId;
  final String userFname;
  final String userMobile;
  final String roleName;
  final String branchMulti;

  UserTeleModel({
    required this.userId,
    required this.userFname,
    required this.userMobile,
    required this.roleName,
    required this.branchMulti,
  });

  factory UserTeleModel.fromJson(Map<String, dynamic> json) {
    return UserTeleModel(
      userId: json["user_id"] ?? "",
      userFname: json["user_fname"] ?? "",
      userMobile: json["user_mobile"] ?? "",
      roleName: json["role_name"] ?? "",
      branchMulti: json["branch_multi"] ?? "",
    );
  }
}
