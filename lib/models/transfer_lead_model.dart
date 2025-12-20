class LeadResponse {
  final String status;
  final int leadCount;
  final List<LeadMaster> leadMaster;

  LeadResponse({
    required this.status,
    required this.leadCount,
    required this.leadMaster,
  });

  factory LeadResponse.fromJson(Map<String, dynamic> json) {
    return LeadResponse(
      status: json["status"] ?? "",
      leadCount: json["leadCount"] ?? 0,
      leadMaster: (json["lead_master"] as List)
          .map((e) => LeadMaster.fromJson(e))
          .toList(),
    );
  }
}

class LeadMaster {
  String? leadId;
  String? mobile;
  String? branchName;
  String? customerName;
  String? product;
  String? leadStatus;
  String? leadDate;
  String? responseId;
  String? clientCode;

  LeadMaster({
    this.leadId,
    this.mobile,
    this.branchName,
    this.customerName,
    this.product,
    this.leadStatus,
    this.leadDate,
    this.responseId,
    this.clientCode,
  });

  factory LeadMaster.fromJson(Map<String, dynamic> json) {
    return LeadMaster(
      leadId: json["lead_id"]?.toString(),
      mobile: json["mobile"]?.toString(),
      branchName: json["branch_name"]?.toString(),
      customerName: json["customer_name"]?.toString(),
      product: json["product"]?.toString(),
      leadStatus: json["lead_status"]?.toString(),
      leadDate: json["lead_date"]?.toString(),
      responseId: json["response_id"]?.toString(),
      clientCode: json["client_code"]?.toString(),
    );
  }
}
