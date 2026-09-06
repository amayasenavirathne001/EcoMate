class SmartAlert {
  final int id;
  final String type;
  final String severity;
  final int? jobId;
  final String? routeId;
  final String? zone;
  final String description;
  final DateTime createdTimestamp;
  final DateTime updatedTimestamp;
  final String status;

  SmartAlert({
    required this.id,
    required this.type,
    required this.severity,
    this.jobId,
    this.routeId,
    this.zone,
    required this.description,
    required this.createdTimestamp,
    required this.updatedTimestamp,
    required this.status,
  });

  factory SmartAlert.fromJson(Map<String, dynamic> json) {
    return SmartAlert(
      id: json['id'],
      type: json['type'],
      severity: json['severity'],
      jobId: json['jobId'],
      routeId: json['routeId'],
      zone: json['zone'],
      description: json['description'],
      createdTimestamp: DateTime.parse(json['createdTimestamp']),
      updatedTimestamp: DateTime.parse(json['updatedTimestamp']),
      status: json['status'],
    );
  }
}
