class DailyLeadReportResponse {
  final String status;
  final int leadCount;
  final List<DailyReportItem> report;

  DailyLeadReportResponse({
    required this.status,
    required this.leadCount,
    required this.report,
  });

  factory DailyLeadReportResponse.fromJson(Map<String, dynamic> json) {
    return DailyLeadReportResponse(
      status: json["status"] ?? "",
      leadCount: int.tryParse(json["leadCount"].toString()) ?? 0,
      report: (json["report"] as List)
          .map((e) => DailyReportItem.fromJson(e))
          .toList(),
    );
  }
}

class DailyReportItem {
  final String client;
  final String fresh;
  final String appFix;
  final String telecaller;
  final String onField;
  final String errorRec;
  final String pickedup;
  final String rto;
  final String rtoDuplicate;
  final String submitted;
  final String total;
  final int pending;
  final int submissionPercentage;

  DailyReportItem({
    required this.client,
    required this.fresh,
    required this.appFix,
    required this.telecaller,
    required this.onField,
    required this.errorRec,
    required this.pickedup,
    required this.rto,
    required this.rtoDuplicate,
    required this.submitted,
    required this.total,
    required this.pending,
    required this.submissionPercentage,
  });

  factory DailyReportItem.fromJson(Map<String, dynamic> json) {
    return DailyReportItem(
      client: json["client"] ?? "",
      fresh: json["Fresh"] ?? "0",
      appFix: json["App_Fix"] ?? "0",
      telecaller: json["telecaller"] ?? "0",
      onField: json["on_field"] ?? "0",
      errorRec: json["error_rec"] ?? "0",
      pickedup: json["pickedup"] ?? "0",
      rto: json["RTO"] ?? "0",
      rtoDuplicate: json["RTO_Duplicate"] ?? "0",
      submitted: json["submitted"] ?? "0",
      total: json["Total"] ?? "0",
      pending: int.tryParse(json["Pending"].toString()) ?? 0,
      submissionPercentage:
      int.tryParse(json["Submission_percentage"].toString()) ?? 0,
    );
  }
}
