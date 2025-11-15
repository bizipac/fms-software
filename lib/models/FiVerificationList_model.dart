class FiVerificationList {
  final String status;
  final int clientCount;
  final List<FiClientItem> client;

  FiVerificationList({
    required this.status,
    required this.clientCount,
    required this.client,
  });

  factory FiVerificationList.fromJson(Map<String, dynamic> json) {
    return FiVerificationList(
      status: json['status'] ?? '',
      clientCount: int.tryParse(json['clientCount']?.toString() ?? '0') ?? 0,
      client: (json['client'] != null && json['client'] is List)
          ? (json['client'] as List)
          .map((item) => FiClientItem.fromJson(item))
          .toList()
          : [], // <-- fallback if client is null or not a list
    );
  }
}

class FiClientItem {
  final String? id;
  final String? leadId;
  final String? clientId;
  final String? mobile;
  final String? customerName;
  final String? status;
  final String? status_name;
  final String? branch_name;

  FiClientItem({
    this.id,
    this.leadId,
    this.clientId,
    this.mobile,
    this.customerName,
    this.status,
    this.status_name,
    this.branch_name,
  });

  factory FiClientItem.fromJson(Map<String, dynamic> json) {
    return FiClientItem(
      id: json['id']?.toString(),
      leadId: json['lead_id']?.toString(),
      clientId: json['client_id']?.toString(),
      mobile: json['mobile']?.toString(),
      customerName: json['customer_name']?.toString(),
      status: json['status']?.toString(),
      status_name: json['status_name']?.toString(),
      branch_name: json['branch_name']?.toString(),
    );
  }
}
