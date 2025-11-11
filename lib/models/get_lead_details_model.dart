class GetLeadDetails {
  final String status;
  final int leadCount;
  final List<LeadMaster> leadMaster;

  GetLeadDetails({
    required this.status,
    required this.leadCount,
    required this.leadMaster,
  });

  // ✅ Factory constructor to decode JSON
  factory GetLeadDetails.fromJson(Map<String, dynamic> json) {
    return GetLeadDetails(
      status: json['status'] ?? '',
      leadCount: json['leadCount'] ?? 0,
      leadMaster: (json['lead_master'] as List<dynamic>?)
          ?.map((e) => LeadMaster.fromJson(e))
          .toList() ??
          [],
    );
  }

  // Optional: encode back to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'leadCount': leadCount,
      'lead_master': leadMaster.map((e) => e.toJson()).toList(),
    };
  }
}

class LeadMaster {
  final int leadId;
  final String mobile;
  final int branchId;
  final int statusId;
  final String leadDate;
  final dynamic leadStatus;
  final int clientId;
  final String customerName;
  final String? product;
  final dynamic productCode;
  final String? formNo;
  final String? source;
  final String? source2;
  final String? source3;
  final String? resData;
  final String resPin;
  final String? offName;
  final String? offAddress;
  final String? offNo;
  final String? offPincode;
  final String doc;
  final String remarks;
  final dynamic pqLeads;
  final dynamic campaignName;
  final dynamic caseId;
  final dynamic surrogate;
  final dynamic seCode;
  final dynamic addOn;
  final dynamic pqKyc;
  final dynamic crmLead;
  final dynamic annualSalary;
  final dynamic yblCustomer;
  final dynamic sourceCode;
  final dynamic asmCode;
  final String? lcCode;
  final String? dvName;
  final String? apptime;
  final String? apploc;
  final dynamic accno;
  final dynamic lgcode;
  final dynamic channelcode;
  final String? logo;
  final dynamic secode;
  final String? compname;
  final dynamic valid;
  final dynamic visitingcard;
  final dynamic utilitybill;
  final String? aadharcard;
  final String? athenaLeadId;
  final dynamic serviceId;
  final String url;
  final String? city;
  final int responseId;
  final String branchName;
  final String clientCode;

  LeadMaster({
    required this.leadId,
    required this.mobile,
    required this.branchId,
    required this.statusId,
    required this.leadDate,
    required this.leadStatus,
    required this.clientId,
    required this.customerName,
    required this.product,
    required this.productCode,
    required this.formNo,
    required this.source,
    required this.source2,
    required this.source3,
    required this.resData,
    required this.resPin,
    required this.offName,
    required this.offAddress,
    required this.offNo,
    required this.offPincode,
    required this.doc,
    required this.remarks,
    required this.pqLeads,
    required this.campaignName,
    required this.caseId,
    required this.surrogate,
    required this.seCode,
    required this.addOn,
    required this.pqKyc,
    required this.crmLead,
    required this.annualSalary,
    required this.yblCustomer,
    required this.sourceCode,
    required this.asmCode,
    required this.lcCode,
    required this.dvName,
    required this.apptime,
    required this.apploc,
    required this.accno,
    required this.lgcode,
    required this.channelcode,
    required this.logo,
    required this.secode,
    required this.compname,
    required this.valid,
    required this.visitingcard,
    required this.utilitybill,
    required this.aadharcard,
    required this.athenaLeadId,
    required this.serviceId,
    required this.url,
    required this.city,
    required this.responseId,
    required this.branchName,
    required this.clientCode,
  });

  // ✅ Factory constructor to decode one lead from JSON
  factory LeadMaster.fromJson(Map<String, dynamic> json) {
    return LeadMaster(
      leadId: int.tryParse(json['lead_id'].toString()) ?? 0,
      mobile: json['mobile'] ?? '',
      branchId: int.tryParse(json['branch_id'].toString()) ?? 0,
      statusId: int.tryParse(json['status_id'].toString()) ?? 0,
      leadDate: json['lead_date'] ?? '',
      leadStatus: json['lead_status'],
      clientId: int.tryParse(json['client_id'].toString()) ?? 0,
      customerName: json['customer_name'] ?? '',
      product: json['product'],
      productCode: json['product_code'],
      formNo: json['form_no'],
      source: json['source'],
      source2: json['source2'],
      source3: json['source3'],
      resData: json['res_data'],
      resPin: json['res_pin'] ?? '',
      offName: json['off_name'],
      offAddress: json['off_address'],
      offNo: json['off_no'],
      offPincode: json['off_pincode'],
      doc: json['doc'] ?? '',
      remarks: json['remarks'] ?? '',
      pqLeads: json['pq_leads'],
      campaignName: json['campaign_name'],
      caseId: json['case_id'],
      surrogate: json['surrogate'],
      seCode: json['se_code'],
      addOn: json['add_on'],
      pqKyc: json['pq_kyc'],
      crmLead: json['crm_lead'],
      annualSalary: json['annual_salary'],
      yblCustomer: json['YBLCustomer'],
      sourceCode: json['source_code'],
      asmCode: json['ASM_code'],
      lcCode: json['LC_code'],
      dvName: json['DV_name'],
      apptime: json['apptime'],
      apploc: json['apploc'],
      accno: json['accno'],
      lgcode: json['lgcode'],
      channelcode: json['channelcode'],
      logo: json['logo'],
      secode: json['secode'],
      compname: json['compname'],
      valid: json['valid'],
      visitingcard: json['visitingcard'],
      utilitybill: json['utilitybill'],
      aadharcard: json['aadharcard'],
      athenaLeadId: json['Athena_lead_id'],
      serviceId: json['service_id'],
      url: json['url'] ?? '',
      city: json['city'],
      responseId: int.tryParse(json['response_id'].toString()) ?? 0,
      branchName: json['branch_name'] ?? '',
      clientCode: json['client_code'] ?? '',
    );
  }

  // Optional: convert object to JSON (useful for POST requests)
  Map<String, dynamic> toJson() {
    return {
      'lead_id': leadId,
      'mobile': mobile,
      'branch_id': branchId,
      'status_id': statusId,
      'lead_date': leadDate,
      'lead_status': leadStatus,
      'client_id': clientId,
      'customer_name': customerName,
      'product': product,
      'product_code': productCode,
      'form_no': formNo,
      'source': source,
      'source2': source2,
      'source3': source3,
      'res_data': resData,
      'res_pin': resPin,
      'off_name': offName,
      'off_address': offAddress,
      'off_no': offNo,
      'off_pincode': offPincode,
      'doc': doc,
      'remarks': remarks,
      'pq_leads': pqLeads,
      'campaign_name': campaignName,
      'case_id': caseId,
      'surrogate': surrogate,
      'se_code': seCode,
      'add_on': addOn,
      'pq_kyc': pqKyc,
      'crm_lead': crmLead,
      'annual_salary': annualSalary,
      'YBLCustomer': yblCustomer,
      'source_code': sourceCode,
      'ASM_code': asmCode,
      'LC_code': lcCode,
      'DV_name': dvName,
      'apptime': apptime,
      'apploc': apploc,
      'accno': accno,
      'lgcode': lgcode,
      'channelcode': channelcode,
      'logo': logo,
      'secode': secode,
      'compname': compname,
      'valid': valid,
      'visitingcard': visitingcard,
      'utilitybill': utilitybill,
      'aadharcard': aadharcard,
      'Athena_lead_id': athenaLeadId,
      'service_id': serviceId,
      'url': url,
      'city': city,
      'response_id': responseId,
      'branch_name': branchName,
      'client_code': clientCode,
    };
  }
}
