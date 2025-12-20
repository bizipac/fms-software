class UserData1 {
  final String userId;
  final String userFname;

  UserData1({
    required this.userId,
    required this.userFname,
  });

  factory UserData1.fromJson(Map<String, dynamic> json) {
    return UserData1(
      userId: json['user_id'] ?? '',
      userFname: json['user_fname'] ?? '',
    );
  }
}
