class LeadTransferResponse {
  final String status;
  final int leadCount;
  final List<LeadMaster> leadMaster;

  LeadTransferResponse({
    required this.status,
    required this.leadCount,
    required this.leadMaster,
  });

  factory LeadTransferResponse.fromJson(Map<String, dynamic> json) {
    return LeadTransferResponse(
      status: json["status"] ?? "",
      leadCount: json["leadCount"] ?? 0,
      leadMaster: (json["lead_master"] as List)
          .map((e) => LeadMaster.fromJson(e))
          .toList(),
    );
  }
}

class LeadMaster {
  final String leadId;
  final String mobile;
  final String branchId;
  final String statusId;
  final String leadDate;
  final String customerName;
  final String? product;
  final String? source;
  final String? appPin;
  final String? city;
  final String? branchName;
  final String? statusName;

  LeadMaster({
    required this.leadId,
    required this.mobile,
    required this.branchId,
    required this.statusId,
    required this.leadDate,
    required this.customerName,
    this.product,
    this.source,
    this.appPin,
    this.city,
    this.branchName,
    this.statusName,
  });

  factory LeadMaster.fromJson(Map<String, dynamic> json) {
    return LeadMaster(
      leadId: json["lead_id"] ?? "",
      mobile: json["mobile"] ?? "",
      branchId: json["branch_id"] ?? "",
      statusId: json["status_id"] ?? "",
      leadDate: json["lead_date"] ?? "",
      customerName: json["customer_name"] ?? "",
      product: json["product"],
      source: json["source"],
      appPin: json["app_pin"],
      city: json["city"],
      branchName: json["branch_name"],
      statusName: json["status_name"],
    );
  }
}
