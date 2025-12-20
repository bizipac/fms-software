class AppFixedModel {
  final String leadId;
  final String responseId;
  final String appPin;
  final String appAdd;
  final String appLocation;
  final String branchId;
  final String doc;
  final String? crmDoc;
  final String product;
  final String customerName;
  final String leadDate;
  final String remarks;
  final String appDate;
  final String appTime;
  final String mobile;
  final String clientId;
  final String statusId;
  final String? url;
  final String response;
  final String parErrStatus;
  final String? clientCode;
  final String statusName;
  final String? uby;
  final String? ufor;
  bool isSelected;

  AppFixedModel({
    required this.leadId,
    required this.responseId,
    required this.appPin,
    required this.appAdd,
    required this.appLocation,
    required this.branchId,
    required this.doc,
    required this.crmDoc,
    required this.product,
    required this.customerName,
    required this.leadDate,
    required this.remarks,
    required this.appDate,
    required this.appTime,
    required this.mobile,
    required this.clientId,
    required this.statusId,
    required this.url,
    required this.response,
    required this.parErrStatus,
    required this.clientCode,
    required this.statusName,
    required this.uby,
    required this.ufor,
    this.isSelected = false,
  });
  Map<String, dynamic> toMap() {
    return {
      "lead_id": leadId,
      "response_id": responseId,
      "app_pin": appPin,
      "app_add": appAdd,
      "app_location": appLocation,
      "branch_id": branchId,
      "doc": doc,
      "crm_doc": crmDoc,
      "product": product,
      "customer_name": customerName,
      "lead_date": leadDate,
      "remarks": remarks,
      "app_date": appDate,
      "app_time": appTime,
      "mobile": mobile,
      "client_id": clientId,
      "status_id": statusId,
      "url": url,
      "response": response,
      "par_err_status": parErrStatus,
      "client_code": clientCode,
      "status_name": statusName,
      "uby": uby,
      "ufor": ufor,
    };
  }

  factory AppFixedModel.fromJson(Map<String, dynamic> json) {
    return AppFixedModel(
      leadId: json['lead_id'] ?? "",
      responseId: json['response_id'] ?? "",
      appPin: json['app_pin'] ?? "",
      appAdd: json['app_add'] ?? "",
      appLocation: json['app_location'] ?? "",
      branchId: json['branch_id'] ?? "",
      doc: json['doc'] ?? "",
      crmDoc: json['crm_doc'],
      product: json['product'] ?? "",
      customerName: json['customer_name'] ?? "",
      leadDate: json['lead_date'] ?? "",
      remarks: json['remarks'] ?? "",
      appDate: json['app_date'] ?? "",
      appTime: json['app_time'] ?? "",
      mobile: json['mobile'] ?? "",
      clientId: json['client_id'] ?? "",
      statusId: json['status_id'] ?? "",
      url: json['url'],
      response: json['response'] ?? "",
      parErrStatus: json['par_err_status'] ?? "",
      clientCode: json['client_code'],
      statusName: json['status_name'] ?? "",
      uby: json['uby'],
      ufor: json['ufor'],
      isSelected: false,
    );
  }
}
