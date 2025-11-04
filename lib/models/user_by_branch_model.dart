class UserByBranchModel {
  final int userId;
  final String userName;
  final String? userToken;

  UserByBranchModel({
    required this.userId,
    required this.userName,
    this.userToken,
  });

  factory UserByBranchModel.fromJson(Map<String, dynamic> json) {
    return UserByBranchModel(
      userId: int.parse(json['user_id'].toString()),
      userName: json['user_fname'] ?? '',
      userToken: json['user_token'],
    );
  }
}
