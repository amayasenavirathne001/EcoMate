class SpecialPickup {
  final int id;
  final String title;
  final String description;
  final String location;
  final String serviceArea;

  final DateTime pickupDate;
  final String startTime;
  final String endTime;
  final DateTime? joinDeadline;

  final List<String> acceptedWasteTypes;

  final int joinedHouseholds;

  // Minimum households required before vehicle assignment.
  final int minHouseholds;

  // Maximum households allowed to join.
  final int maxHouseholds;

  final double currentEstimatedWeightKg;
  final double maxWeightKg;

  final double currentEstimatedVolumeM3;
  final double maxVolumeM3;

  final String status;
  final String? userJoinStatus;

  // Admin cancellation reason.
  final String? cancellationReason;

  const SpecialPickup({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.serviceArea,
    required this.pickupDate,
    required this.startTime,
    required this.endTime,
    required this.joinDeadline,
    required this.acceptedWasteTypes,
    required this.joinedHouseholds,
    required this.minHouseholds,
    required this.maxHouseholds,
    required this.currentEstimatedWeightKg,
    required this.maxWeightKg,
    required this.currentEstimatedVolumeM3,
    required this.maxVolumeM3,
    required this.status,
    this.userJoinStatus,
    this.cancellationReason,
  });

  factory SpecialPickup.fromJson(
    Map<String, dynamic> json,
  ) {
    return SpecialPickup(
      id: (json['id'] as num).toInt(),

      title:
          json['title']?.toString() ?? '',

      description:
          json['description']?.toString() ?? '',

      location:
          json['location']?.toString() ?? '',

      serviceArea:
          json['serviceArea']?.toString() ?? '',

      pickupDate:
          DateTime.parse(
        json['pickupDate'].toString(),
      ),

      startTime:
          json['startTime']?.toString() ?? '',

      endTime:
          json['endTime']?.toString() ?? '',

      joinDeadline:
          json['joinDeadline'] != null
              ? DateTime.tryParse(
                  json['joinDeadline'].toString(),
                )
              : null,

      acceptedWasteTypes:
          _parseWasteTypes(
        json['acceptedWasteTypes'],
      ),

      joinedHouseholds:
          (json['joinedHouseholds'] as num?)
                  ?.toInt() ??
              0,

      // Existing old pickups may not have this field.
      // In that case we use 4 as the fallback.
      minHouseholds:
          (json['minHouseholds'] as num?)
                  ?.toInt() ??
              4,

      maxHouseholds:
          (json['maxHouseholds'] as num?)
                  ?.toInt() ??
              0,

      currentEstimatedWeightKg:
          (json['currentEstimatedWeightKg']
                      as num?)
                  ?.toDouble() ??
              0.0,

      maxWeightKg:
          (json['maxWeightKg'] as num?)
                  ?.toDouble() ??
              0.0,

      currentEstimatedVolumeM3:
          (json['currentEstimatedVolumeM3']
                      as num?)
                  ?.toDouble() ??
              0.0,

      maxVolumeM3:
          (json['maxVolumeM3'] as num?)
                  ?.toDouble() ??
              0.0,

      status:
          json['status']?.toString() ?? '',

      userJoinStatus:
          json['userJoinStatus']?.toString(),

      cancellationReason:
          json['cancellationReason']?.toString(),
    );
  }

  // =========================================================
  // WASTE TYPES
  // =========================================================

  static List<String> _parseWasteTypes(
    dynamic value,
  ) {
    if (value == null) {
      return [];
    }

    // Supports:
    // "Furniture,Electronic Waste,Bulky Waste"
    if (value is String) {
      return value
          .split(',')
          .map(
            (item) => item.trim(),
          )
          .where(
            (item) => item.isNotEmpty,
          )
          .toList();
    }

    // Also supports:
    // ["Furniture", "Electronic Waste", "Bulky Waste"]
    if (value is List) {
      return value
          .map(
            (item) =>
                item.toString().trim(),
          )
          .where(
            (item) => item.isNotEmpty,
          )
          .toList();
    }

    return [];
  }

  // =========================================================
  // JOIN STATUS HELPERS
  // =========================================================

  bool get hasJoinRequest {
    return userJoinStatus != null &&
        userJoinStatus!.trim().isNotEmpty;
  }

  bool get isPending {
    return userJoinStatus ==
        'PENDING_APPROVAL';
  }

  bool get isApproved {
    return userJoinStatus == 'APPROVED';
  }

  bool get isRejected {
    return userJoinStatus == 'REJECTED';
  }

  // =========================================================
  // PICKUP STATUS HELPERS
  // =========================================================

  bool get isScheduled {
    return status == 'SCHEDULED';
  }

  bool get isAssigned {
    return status == 'ASSIGNED';
  }

  bool get isFull {
    return status == 'FULL';
  }

  bool get isInProgress {
    return status == 'IN_PROGRESS';
  }

  bool get isCompleted {
    return status == 'COMPLETED';
  }

  bool get isCancelled {
    return status == 'CANCELLED';
  }

  // =========================================================
  // MINIMUM PARTICIPATION
  // =========================================================

  bool get minimumParticipationReached {
    return joinedHouseholds >= minHouseholds;
  }

  int get householdsNeededForMinimum {
    final remaining =
        minHouseholds - joinedHouseholds;

    return remaining < 0 ? 0 : remaining;
  }

  bool get canAssignVehicle {
    return isScheduled &&
        minimumParticipationReached;
  }

  // =========================================================
  // CAPACITY HELPERS
  // =========================================================

  bool get hasAvailableHouseholdSpace {
    return joinedHouseholds <
        maxHouseholds;
  }

  double get remainingWeightKg {
    final remaining =
        maxWeightKg -
        currentEstimatedWeightKg;

    return remaining < 0
        ? 0
        : remaining;
  }

  double get remainingVolumeM3 {
    final remaining =
        maxVolumeM3 -
        currentEstimatedVolumeM3;

    return remaining < 0
        ? 0
        : remaining;
  }

  int get remainingHouseholds {
    final remaining =
        maxHouseholds -
        joinedHouseholds;

    return remaining < 0
        ? 0
        : remaining;
  }

  // =========================================================
  // JOIN DEADLINE
  // =========================================================

  bool get joinDeadlinePassed {
    if (joinDeadline == null) {
      return false;
    }

    return DateTime.now().isAfter(
      joinDeadline!,
    );
  }

  // =========================================================
  // RESIDENT JOIN AVAILABILITY
  // =========================================================

  bool get canJoin {
    return isScheduled &&
        !hasJoinRequest &&
        !joinDeadlinePassed &&
        hasAvailableHouseholdSpace &&
        remainingWeightKg > 0 &&
        remainingVolumeM3 > 0;
  }
}