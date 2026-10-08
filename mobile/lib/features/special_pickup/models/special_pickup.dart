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
  final int maxHouseholds;

  final double currentEstimatedWeightKg;
  final double maxWeightKg;

  final double currentEstimatedVolumeM3;
  final double maxVolumeM3;

  final String status;
  final String? userJoinStatus;

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
    required this.maxHouseholds,
    required this.currentEstimatedWeightKg,
    required this.maxWeightKg,
    required this.currentEstimatedVolumeM3,
    required this.maxVolumeM3,
    required this.status,
    this.userJoinStatus,
  });

  factory SpecialPickup.fromJson(Map<String, dynamic> json) {
    return SpecialPickup(
      id: (json['id'] as num).toInt(),

      title: json['title']?.toString() ?? '',

      description: json['description']?.toString() ?? '',

      location: json['location']?.toString() ?? '',

      serviceArea: json['serviceArea']?.toString() ?? '',

      pickupDate: DateTime.parse(json['pickupDate'].toString()),

      startTime: json['startTime']?.toString() ?? '',

      endTime: json['endTime']?.toString() ?? '',

      joinDeadline: json['joinDeadline'] != null
          ? DateTime.tryParse(json['joinDeadline'].toString())
          : null,

      acceptedWasteTypes: _parseWasteTypes(json['acceptedWasteTypes']),

      joinedHouseholds: (json['joinedHouseholds'] as num?)?.toInt() ?? 0,

      maxHouseholds: (json['maxHouseholds'] as num?)?.toInt() ?? 0,

      currentEstimatedWeightKg:
          (json['currentEstimatedWeightKg'] as num?)?.toDouble() ?? 0.0,

      maxWeightKg: (json['maxWeightKg'] as num?)?.toDouble() ?? 0.0,

      currentEstimatedVolumeM3:
          (json['currentEstimatedVolumeM3'] as num?)?.toDouble() ?? 0.0,

      maxVolumeM3: (json['maxVolumeM3'] as num?)?.toDouble() ?? 0.0,

      status: json['status']?.toString() ?? '',

      userJoinStatus: json['userJoinStatus']?.toString(),
    );
  }

  static List<String> _parseWasteTypes(dynamic value) {
    if (value == null) {
      return [];
    }

    // Supports a backend response such as:
    // "Furniture,Electronics,Garden Waste"
    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    // Also supports a future backend response such as:
    // ["Furniture", "Electronics", "Garden Waste"]
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [];
  }

  // ---------------------------------------------------------
  // JOIN STATUS HELPERS
  // ---------------------------------------------------------

  bool get hasJoinRequest {
    return userJoinStatus != null && userJoinStatus!.trim().isNotEmpty;
  }

  bool get isPending {
    return userJoinStatus == 'PENDING_APPROVAL';
  }

  bool get isApproved {
    return userJoinStatus == 'APPROVED';
  }

  bool get isRejected {
    return userJoinStatus == 'REJECTED';
  }

  bool get hasAvailableHouseholdSpace {
    return joinedHouseholds < maxHouseholds;
  }

  // ---------------------------------------------------------
  // CAPACITY HELPERS
  // ---------------------------------------------------------

  double get remainingWeightKg {
    final remaining = maxWeightKg - currentEstimatedWeightKg;

    return remaining < 0 ? 0 : remaining;
  }

  double get remainingVolumeM3 {
    final remaining = maxVolumeM3 - currentEstimatedVolumeM3;

    return remaining < 0 ? 0 : remaining;
  }

  int get remainingHouseholds {
    final remaining = maxHouseholds - joinedHouseholds;

    return remaining < 0 ? 0 : remaining;
  }
  // ---------------------------------------------------------
  // JOIN AVAILABILITY
  // ---------------------------------------------------------

  bool get joinDeadlinePassed {
    if (joinDeadline == null) {
      return false;
    }

    return DateTime.now().isAfter(joinDeadline!);
  }

  bool get isAssigned {
    return status == 'ASSIGNED';
  }

  bool get isFull {
    return status == 'FULL';
  }

  bool get canJoin {
    return isAssigned &&
        !hasJoinRequest &&
        !joinDeadlinePassed &&
        hasAvailableHouseholdSpace &&
        remainingWeightKg > 0 &&
        remainingVolumeM3 > 0;
  }
}