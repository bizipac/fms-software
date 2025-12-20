class CallLaterResponse {
  final String status;
  final int leadCount;
  final List<CallLaterLead> callLater;

  CallLaterResponse({
    required this.status,
    required this.leadCount,
    required this.callLater,
  });

  factory CallLaterResponse.fromJson(Map<String, dynamic> json) {
    return CallLaterResponse(
      status: json['status'] ?? '',
      leadCount: int.parse(json['leadCount'].toString()),
      callLater: (json['Call_Later'] as List)
          .map((e) => CallLaterLead.fromJson(e))
          .toList(),
    );
  }
}

class CallLaterLead {
  final String leadId;
  final String mobile;
  final String branchId;
  final String statusId;
  final String leadDate;
  final String leadStatus;
  final String clientId;
  final String customerName;
  final String product;
  final String source;
  final String? resPin;
  final String? offPincode;
  final String city;
  final String responseId;
  final String appDate;
  final String appTime;
  final String? docCollected;
  final String updatedBy;
  final String updatedFor;
  final String? appPin;
  final String clientCode;
  final String statusName;
  final String uby;
  final String ufor;

  CallLaterLead({
    required this.leadId,
    required this.mobile,
    required this.branchId,
    required this.statusId,
    required this.leadDate,
    required this.leadStatus,
    required this.clientId,
    required this.customerName,
    required this.product,
    required this.source,
    this.resPin,
    this.offPincode,
    required this.city,
    required this.responseId,
    required this.appDate,
    required this.appTime,
    this.docCollected,
    required this.updatedBy,
    required this.updatedFor,
    this.appPin,
    required this.clientCode,
    required this.statusName,
    required this.uby,
    required this.ufor,
  });

  factory CallLaterLead.fromJson(Map<String, dynamic> json) {
    return CallLaterLead(
      leadId: json['lead_id'] ?? '',
      mobile: json['mobile'] ?? '',
      branchId: json['branch_id'] ?? '',
      statusId: json['status_id'] ?? '',
      leadDate: json['lead_date'] ?? '',
      leadStatus: json['lead_status'] ?? '',
      clientId: json['client_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      product: json['product'] ?? '',
      source: json['source'] ?? '',
      resPin: json['res_pin'],
      offPincode: json['off_pincode'],
      city: json['city'] ?? '',
      responseId: json['response_id'] ?? '',
      appDate: json['app_date'] ?? '',
      appTime: json['app_time'] ?? '',
      docCollected: json['doc_collected'],
      updatedBy: json['updatedby'] ?? '',
      updatedFor: json['updatedfor'] ?? '',
      appPin: json['app_pin'],
      clientCode: json['client_code'] ?? '',
      statusName: json['status_name'] ?? '',
      uby: json['uby'] ?? '',
      ufor: json['ufor'] ?? '',
    );
  }
}
