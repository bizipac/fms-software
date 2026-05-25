class DashboardResponse {
  final String status;
  final Dashboard dashboard;

  DashboardResponse({
    required this.status,
    required this.dashboard,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'],
      dashboard: Dashboard.fromJson(json['dashboard']),
    );
  }
}

class Dashboard {
  final TcDashboard tcDashboard;
  final CommonDashboard onFieldDashboard;
  final CommonDashboard appFixedDashboard;

  Dashboard({
    required this.tcDashboard,
    required this.onFieldDashboard,
    required this.appFixedDashboard,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      tcDashboard: TcDashboard.fromJson(json['tc_dashboard']),
      onFieldDashboard:
      CommonDashboard.fromJson(json['onfield_dashboard']),
      appFixedDashboard:
      CommonDashboard.fromJson(json['appfixed_dashboard']),
    );
  }
}

class TcDashboard {
  final int pendingOverdue;
  final int pending;
  final int telecalling;

  TcDashboard({
    required this.pendingOverdue,
    required this.pending,
    required this.telecalling,
  });

  factory TcDashboard.fromJson(Map<String, dynamic> json) {
    return TcDashboard(
      pendingOverdue: json['pending_overdue'],
      pending: json['pending'],
      telecalling: json['telecalling'],
    );
  }
}

class CommonDashboard {
  final int pendingBeforeToday;
  final int today;
  final int future;

  CommonDashboard({
    required this.pendingBeforeToday,
    required this.today,
    required this.future,
  });

  factory CommonDashboard.fromJson(Map<String, dynamic> json) {
    return CommonDashboard(
      pendingBeforeToday: json['pending_before_today'],
      today: json['today'],
      future: json['future'],
    );
  }
}
