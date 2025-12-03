// FieldReportAiModel.dart
// Generated model classes for the provided JSON response

import 'dart:convert';

FieldReportAiModel leadResponseModelFromJson(String str) =>
    FieldReportAiModel.fromJson(json.decode(str));

String leadResponseModelToJson(FieldReportAiModel data) => json.encode(data.toJson());

class FieldReportAiModel {
  FieldReportAiModel({
    required this.status,
    required this.leadCount,
    required this.fieldexecutive,
  });

  String status;
  int leadCount;
  List<FieldExecutive> fieldexecutive;

  factory FieldReportAiModel.fromJson(Map<String, dynamic> json) => FieldReportAiModel(
    status: json["status"] ?? '',
    leadCount: json["leadCount"] is int
        ? json["leadCount"]
        : int.tryParse(json["leadCount"]?.toString() ?? '0') ?? 0,
    fieldexecutive: json["fieldexecutive"] == null
        ? []
        : List<FieldExecutive>.from(
      (json["fieldexecutive"] as List).map((x) => FieldExecutive.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "leadCount": leadCount,
    "fieldexecutive": List<dynamic>.from(fieldexecutive.map((x) => x.toJson())),
  };
}

class FieldExecutive {
  FieldExecutive({
    required this.leadId,
    required this.branchName,
    this.appDate,
    this.appTime,
    this.doc,
    this.appAdd,
    this.appPin,
    this.mobile,
    this.customerName,
    this.product,
    this.athenaLeadId,
    this.remarks,
    this.clientCode,
    this.ufor,
    this.uby,
    this.statusId,
    this.firstcall,
    this.lastcall,
    this.callType,
    this.dialCallStatus,
    this.dialCallDuration,
    required this.callCount,
    this.recordingUrl,
  });

  String leadId;
  String branchName;
  String? appDate;
  String? appTime;
  String? doc;
  String? appAdd;
  String? appPin;
  String? mobile;
  String? customerName;
  String? product;
  String? athenaLeadId;
  String? remarks;
  String? clientCode;
  String? ufor;
  String? uby;
  String? statusId;
  String? firstcall;
  String? lastcall;
  String? callType;
  String? dialCallStatus;
  String? dialCallDuration;
  String callCount;
  String? recordingUrl;

  factory FieldExecutive.fromJson(Map<String, dynamic> json) => FieldExecutive(
    leadId: json["lead_id"]?.toString() ?? '',
    branchName: json["branch_name"]?.toString() ?? '',
    appDate: json["app_date"]?.toString(),
    appTime: json["app_time"]?.toString(),
    doc: json["doc"]?.toString(),
    appAdd: json["app_add"]?.toString(),
    appPin: json["app_pin"]?.toString(),
    mobile: json["mobile"]?.toString(),
    customerName: json["customer_name"]?.toString(),
    product: json["product"]?.toString(),
    athenaLeadId: json["Athena_lead_id"]?.toString(),
    remarks: json["remarks"]?.toString(),
    clientCode: json["client_code"]?.toString(),
    ufor: json["ufor"]?.toString(),
    uby: json["uby"]?.toString(),
    statusId: json["status_id"]?.toString(),
    firstcall: json["firstcall"]?.toString(),
    lastcall: json["lastcall"]?.toString(),
    callType: json["CallType"]?.toString(),
    dialCallStatus: json["DialCallStatus"]?.toString(),
    dialCallDuration: json["DialCallDuration"]?.toString(),
    callCount: json["call_count"]?.toString() ?? '0',
    recordingUrl: json["RecordingUrl"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "lead_id": leadId,
    "branch_name": branchName,
    "app_date": appDate,
    "app_time": appTime,
    "doc": doc,
    "app_add": appAdd,
    "app_pin": appPin,
    "mobile": mobile,
    "customer_name": customerName,
    "product": product,
    "Athena_lead_id": athenaLeadId,
    "remarks": remarks,
    "client_code": clientCode,
    "ufor": ufor,
    "uby": uby,
    "status_id": statusId,
    "firstcall": firstcall,
    "lastcall": lastcall,
    "CallType": callType,
    "DialCallStatus": dialCallStatus,
    "DialCallDuration": dialCallDuration,
    "call_count": callCount,
    "RecordingUrl": recordingUrl,
  };
}

// Example usage:
// final model = leadResponseModelFromJson(jsonString);
// print(model.fieldexecutive[0].customerName);
