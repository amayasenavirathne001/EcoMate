import 'package:latlong2/latlong.dart';

enum VehicleStatus {
  onRoute,
  delayed,
  stopped,
}

class LiveVehicleLocation {
  final String vehicleId;
  final String registrationNumber;
  final String routeId;
  final String zone;
  final LatLng location;
  final VehicleStatus status;
  final DateTime lastUpdated;
  final String driverName;
  final double completionPercentage;

  LiveVehicleLocation({
    required this.vehicleId,
    required this.registrationNumber,
    required this.routeId,
    required this.zone,
    required this.location,
    required this.status,
    required this.lastUpdated,
    required this.driverName,
    required this.completionPercentage,
  });

  LiveVehicleLocation copyWith({
    String? vehicleId,
    String? registrationNumber,
    String? routeId,
    String? zone,
    LatLng? location,
    VehicleStatus? status,
    DateTime? lastUpdated,
    String? driverName,
    double? completionPercentage,
  }) {
    return LiveVehicleLocation(
      vehicleId: vehicleId ?? this.vehicleId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      routeId: routeId ?? this.routeId,
      zone: zone ?? this.zone,
      location: location ?? this.location,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      driverName: driverName ?? this.driverName,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
