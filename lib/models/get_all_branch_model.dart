class GetAllBranchModel {
  final String branchId;
  final String branchName;

  GetAllBranchModel({required this.branchId, required this.branchName});

  factory GetAllBranchModel.fromJson(Map<String, dynamic> json) {
    return GetAllBranchModel(
      branchId: json['branch_id'].toString(),
      branchName: json['branch_name'] ?? '',
    );
  }

}
