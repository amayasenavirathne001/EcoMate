class WasteDeliveryRecord {
  final String id;
  final String? recyclingCentreId;
  final String? recyclingCentreName;
  final String materialType;
  final double weightKg;
  final String deliveredBy;
  final String contactNumber;
  final DateTime dateTime;
  final String notes;

  const WasteDeliveryRecord({
    required this.id,
    this.recyclingCentreId,
    this.recyclingCentreName,
    required this.materialType,
    required this.weightKg,
    required this.deliveredBy,
    required this.contactNumber,
    required this.dateTime,
    required this.notes,
  });

  factory WasteDeliveryRecord.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = json['dateTime'] != null
          ? DateTime.parse(json['dateTime'].toString())
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return WasteDeliveryRecord(
      id: json['id'] != null ? 'DEL-${json['id']}' : 'DEL-0',
      recyclingCentreId: json['recyclingCentreId']?.toString(),
      recyclingCentreName: json['recyclingCentreName']?.toString(),
      materialType: json['materialType']?.toString() ?? '',
      weightKg: (json['weightKg'] is num) ? (json['weightKg'] as num).toDouble() : 0.0,
      deliveredBy: json['deliveredBy']?.toString() ?? '',
      contactNumber: json['contactNumber']?.toString() ?? '',
      dateTime: parsedDate,
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recyclingCentreId': recyclingCentreId != null ? int.tryParse(recyclingCentreId!) : null,
      'materialType': materialType,
      'weightKg': weightKg,
      'deliveredBy': deliveredBy,
      'contactNumber': contactNumber,
      'notes': notes,
    };
  }

  /// Calculates eco reward credits based on material category and quantity (SCRUM-57)
  int get ecoPoints {
    final lower = materialType.toLowerCase();
    double multiplier = 10;
    if (lower.contains('plastic')) {
      multiplier = 15;
    } else if (lower.contains('metal') || lower.contains('aluminum')) {
      multiplier = 25;
    } else if (lower.contains('e-waste') || lower.contains('electronic')) {
      multiplier = 30;
    } else if (lower.contains('paper') || lower.contains('cardboard')) {
      multiplier = 10;
    } else if (lower.contains('glass')) {
      multiplier = 8;
    } else if (lower.contains('tetra')) {
      multiplier = 12;
    } else if (lower.contains('organic')) {
      multiplier = 5;
    }
    return (weightKg * multiplier).round();
  }

  /// Calculates estimated CO2 emissions avoided (kg) (SCRUM-57)
  double get co2SavedKg {
    final lower = materialType.toLowerCase();
    double multiplier = 1.2;
    if (lower.contains('plastic')) {
      multiplier = 1.8;
    } else if (lower.contains('metal') || lower.contains('aluminum')) {
      multiplier = 3.5;
    } else if (lower.contains('e-waste') || lower.contains('electronic')) {
      multiplier = 4.0;
    } else if (lower.contains('paper') || lower.contains('cardboard')) {
      multiplier = 1.2;
    } else if (lower.contains('glass')) {
      multiplier = 0.8;
    } else if (lower.contains('tetra')) {
      multiplier = 1.0;
    } else if (lower.contains('organic')) {
      multiplier = 0.5;
    }
    return weightKg * multiplier;
  }

  /// Returns official recycling classification code
  String get materialCode {
    final lower = materialType.toLowerCase();
    if (lower.contains('plastic')) return 'PET #1';
    if (lower.contains('metal') || lower.contains('aluminum')) return 'ALU #41';
    if (lower.contains('e-waste') || lower.contains('electronic')) return 'WEEE';
    if (lower.contains('paper') || lower.contains('cardboard')) return 'PAP #20';
    if (lower.contains('glass')) return 'GL #70';
    if (lower.contains('tetra')) return 'C/PAP #84';
    if (lower.contains('organic')) return 'ORG';
    return 'REC';
  }
}
