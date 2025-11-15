class ClientModel {
  final String clientId;
  final String clientCode;
  final String clientName;
  final String clientStatus;
  final String clientSenderId;
  final String clientType;
  final String clientProduct;

  ClientModel({
    required this.clientId,
    required this.clientCode,
    required this.clientName,
    required this.clientStatus,
    required this.clientSenderId,
    required this.clientType,
    required this.clientProduct,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientId: json['client_id'] ?? '',
      clientCode: json['client_code'] ?? '',
      clientName: json['client_name'] ?? '',
      clientStatus: json['client_status'] ?? '',
      clientSenderId: json['client_senderid'] ?? '',
      clientType: json['client_type'] ?? '',
      clientProduct: json['client_product'] ?? '',
    );
  }
}
