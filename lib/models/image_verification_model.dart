class Imageverification {
  String? status;
  int? clientCount;
  List<Client>? client;
  String? ca;

  Imageverification({this.status, this.clientCount, this.client, this.ca});

  Imageverification.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    clientCount = json['clientCount'];
    if (json['client'] != null) {
      client = <Client>[];
      json['client'].forEach((v) {
        client!.add(new Client.fromJson(v));
      });
    }
    ca = json['ca'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['clientCount'] = this.clientCount;
    if (this.client != null) {
      data['client'] = this.client!.map((v) => v.toJson()).toList();
    }
    data['ca'] = this.ca;
    return data;
  }
}

class Client {
  String? leadId;
  String? clientId;
  String? branchName;
  String? createDate;
  String? responseId;
  String? cnt;
  String? documentId;
  String? documentList;
  String? doc;
  String? documentFile;
  String? verifyBy;
  String? customerName;
  String? mobile;
  String? feName;

  Client(
      {this.leadId,
        this.clientId,
        this.branchName,
        this.createDate,
        this.responseId,
        this.cnt,
        this.documentId,
        this.documentList,
        this.doc,
        this.documentFile,
        this.verifyBy,
        this.customerName,
        this.mobile,
        this.feName});

  Client.fromJson(Map<String, dynamic> json) {
    leadId = json['lead_id'];
    clientId = json['client_id'];
    branchName = json['branch_name'];
    createDate = json['create_date'];
    responseId = json['response_id'];
    cnt = json['cnt'];
    documentId = json['document_id'];
    documentList = json['document_list'];
    doc = json['doc'];
    documentFile = json['document_file'];
    verifyBy = json['verify_by'];
    customerName = json['customer_name'];
    mobile = json['mobile'];
    feName = json['fe_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lead_id'] = this.leadId;
    data['client_id'] = this.clientId;
    data['branch_name'] = this.branchName;
    data['create_date'] = this.createDate;
    data['response_id'] = this.responseId;
    data['cnt'] = this.cnt;
    data['document_id'] = this.documentId;
    data['document_list'] = this.documentList;
    data['doc'] = this.doc;
    data['document_file'] = this.documentFile;
    data['verify_by'] = this.verifyBy;
    data['customer_name'] = this.customerName;
    data['mobile'] = this.mobile;
    data['fe_name'] = this.feName;
    return data;
  }
}
