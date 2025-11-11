class LeadHistoryResponse {
  final String status;
  final int leadCount;
  final int leadMaster;
  final List<CrmRecord> crm;
  final dynamic fecall;
  final int cnt;

  LeadHistoryResponse({
    required this.status,
    required this.leadCount,
    required this.leadMaster,
    required this.crm,
    this.fecall,
    required this.cnt,
  });

  factory LeadHistoryResponse.fromJson(Map<String, dynamic> json) {
    return LeadHistoryResponse(
      status: json['status'] ?? '',
      leadCount: json['leadCount'] ?? 0,
      leadMaster: json['lead_master'] ?? 0,
      crm: (json['crm'] as List?)
          ?.map((e) => CrmRecord.fromJson(e))
          .toList() ??
          [],
      fecall: json['fecall'],
      cnt: json['cnt'] ?? 0,
    );
  }
}

class CrmRecord {
  final String? leadId;
  final String? branchId;
  final String? statusId;
  final String? leadDate;
  final String? clientId;
  final String? product;
  final String? doc;
  final String? remarks;
  final String? url;
  final String? responseId;
  final String? response;
  final String? appDate;
  final String? appTime;
  final String? resTimestamp;
  final String? ufor;
  final String? uby;
  final String? expose;

  CrmRecord({
    this.leadId,
    this.branchId,
    this.statusId,
    this.leadDate,
    this.clientId,
    this.product,
    this.doc,
    this.remarks,
    this.url,
    this.responseId,
    this.response,
    this.appDate,
    this.appTime,
    this.resTimestamp,
    this.ufor,
    this.uby,
    this.expose,
  });

  factory CrmRecord.fromJson(Map<String, dynamic> json) {
    return CrmRecord(
      leadId: json['lead_id'],
      branchId: json['branch_id'],
      statusId: json['status_id'],
      leadDate: json['lead_date'],
      clientId: json['client_id'],
      product: json['product'],
      doc: json['doc'],
      remarks: json['remarks'],
      url: json['url'],
      responseId: json['response_id'],
      response: json['response'],
      appDate: json['app_date'],
      appTime: json['app_time'],
      resTimestamp: json['res_timestamp'],
      ufor: json['ufor'],
      uby: json['uby'],
      expose: json['expose'],
    );
  }
}
