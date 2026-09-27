enum PickupStatus {
  submitted,
  approved,
  scheduled,
  collectorAssigned,
  inProgress,
  completed,
  rejected,
  failed,
}

class PickupRequest {
  final String id;
  final String wasteType;
  final String description;
  final String address;
  final DateTime submittedDate;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String? collectorName;
  final PickupStatus status;
  final String? notes;

  const PickupRequest({
    required this.id,
    required this.wasteType,
    required this.description,
    required this.address,
    required this.submittedDate,
    this.scheduledDate,
    this.scheduledTime,
    this.collectorName,
    required this.status,
    this.notes,
  });
}
