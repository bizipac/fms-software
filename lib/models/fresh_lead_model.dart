class AssignToTLModel {
  String status;
  int leadCount;
  List<FreshLeadItem> fresh;

  AssignToTLModel({
    required this.status,
    required this.leadCount,
    required this.fresh,
  });

  factory AssignToTLModel.fromJson(Map<String, dynamic> json) {
    return AssignToTLModel(
      status: json["status"] ?? "",
      leadCount: json["leadCount"] ?? 0,
      fresh: json["fresh"] == null
          ? []
          : List<FreshLeadItem>.from(
          json["fresh"].map((x) => FreshLeadItem.fromJson(x))),
    );
  }
}

class FreshLeadItem {
  String? leadId;
  String? clientId;
  String? branchId;
  String? resPin;
  String? leadDate;
  String? source;
  String? product;
  String? customerName;
  String? caseId;
  String? mobile;
  String? formNo;
  String? statusId;
  String? clientCode;
  String? statusName;
  String? city;

  FreshLeadItem({
    this.leadId,
    this.clientId,
    this.branchId,
    this.resPin,
    this.leadDate,
    this.source,
    this.product,
    this.customerName,
    this.caseId,
    this.mobile,
    this.formNo,
    this.statusId,
    this.clientCode,
    this.statusName,
    this.city,
  });

  factory FreshLeadItem.fromJson(Map<String, dynamic> json) {
    return FreshLeadItem(
      leadId: json["lead_id"],
      clientId: json["client_id"],
      branchId: json["branch_id"],
      resPin: json["res_pin"],
      leadDate: json["lead_date"],
      source: json["source"],
      product: json["product"],
      customerName: json["customer_name"],
      caseId: json["case_id"],
      mobile: json["mobile"],
      formNo: json["form_no"],
      statusId: json["status_id"],
      clientCode: json["client_code"],
      statusName: json["status_name"],
      city: json["city"],
    );
  }
}
