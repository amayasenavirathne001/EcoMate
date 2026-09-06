import 'recycling_centre.dart';

class RouteModel {
  final int id;
  final String routeCode;
  final String routeName;
  final String areaOrZone;
  final String description;
  final String status;

  RouteModel({
    required this.id,
    required this.routeCode,
    required this.routeName,
    required this.areaOrZone,
    required this.description,
    required this.status,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as int,
      routeCode: json['routeCode'] as String? ?? '',
      routeName: json['routeName'] as String? ?? '',
      areaOrZone: json['areaOrZone'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeCode': routeCode,
      'routeName': routeName,
      'areaOrZone': areaOrZone,
      'description': description,
      'status': status,
    };
  }
}

class CollectionScheduleModel {
  final int? id;
  final String scheduleName;
  final int routeId;
  final RouteModel? route;
  final String areaOrZone;
  final String wasteCategoryId;
  final String collectionDateOrDay;
  final String startTime;
  final String endTime;
  final String frequency;
  final String destinationType;
  final String? recyclingCenterId;
  final RecyclingCentre? recyclingCenter;
  final String status;
  final String resourceStatus;

  CollectionScheduleModel({
    this.id,
    required this.scheduleName,
    required this.routeId,
    this.route,
    required this.areaOrZone,
    required this.wasteCategoryId,
    required this.collectionDateOrDay,
    required this.startTime,
    required this.endTime,
    required this.frequency,
    required this.destinationType,
    this.recyclingCenterId,
    this.recyclingCenter,
    required this.status,
    required this.resourceStatus,
  });

  factory CollectionScheduleModel.fromJson(Map<String, dynamic> json) {
    // Map RecyclingCentre from backend structure if present
    RecyclingCentre? center;
    if (json['recyclingCenter'] != null) {
      final rc = json['recyclingCenter'];
      center = RecyclingCentre(
        id: rc['id'] as String,
        name: rc['name'] as String? ?? '',
        address: rc['address'] as String? ?? '',
        city: rc['city'] as String? ?? '',
        distanceKm: (rc['distanceKm'] as num?)?.toDouble() ?? 0.0,
        contactNumber: rc['contactNumber'] as String? ?? '',
        email: rc['email'] as String? ?? '',
        operatingHours: rc['operatingHours'] as String? ?? '',
        isOpen: rc['open'] as bool? ?? true,
        acceptedMaterials: List<String>.from(rc['acceptedMaterials'] ?? []),
        unsupportedMaterials: List<String>.from(rc['unsupportedMaterials'] ?? []),
        notes: rc['notes'] as String? ?? '',
      );
    }

    return CollectionScheduleModel(
      id: json['id'] as int?,
      scheduleName: json['scheduleName'] as String? ?? '',
      routeId: json['routeId'] as int? ?? 0,
      route: json['route'] != null ? RouteModel.fromJson(json['route']) : null,
      areaOrZone: json['areaOrZone'] as String? ?? '',
      wasteCategoryId: json['wasteCategoryId'] as String? ?? '',
      collectionDateOrDay: json['collectionDateOrDay'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      destinationType: json['destinationType'] as String? ?? '',
      recyclingCenterId: json['recyclingCenterId'] as String?,
      recyclingCenter: center,
      status: json['status'] as String? ?? 'ACTIVE',
      resourceStatus: json['resourceStatus'] as String? ?? 'Not Assigned',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'scheduleName': scheduleName,
      'routeId': routeId,
      'areaOrZone': areaOrZone,
      'wasteCategoryId': wasteCategoryId,
      'collectionDateOrDay': collectionDateOrDay,
      'startTime': startTime,
      'endTime': endTime,
      'frequency': frequency,
      'destinationType': destinationType,
      if (recyclingCenterId != null) 'recyclingCenterId': recyclingCenterId,
      'status': status,
      'resourceStatus': resourceStatus,
    };
  }
}
