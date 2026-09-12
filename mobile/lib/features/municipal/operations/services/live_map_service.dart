import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/live_vehicle_location.dart';

class LiveMapService {
  // Singleton pattern
  static final LiveMapService _instance = LiveMapService._internal();
  factory LiveMapService() => _instance;
  LiveMapService._internal() {
    _initializeMockData();
    _startSimulation();
  }

  final _locationController = StreamController<List<LiveVehicleLocation>>.broadcast();
  List<LiveVehicleLocation> _currentLocations = [];
  Timer? _timer;
  final Random _random = Random();

  Stream<List<LiveVehicleLocation>> get locationStream => _locationController.stream;

  List<LiveVehicleLocation> getCurrentLocations() => _currentLocations;

  void _initializeMockData() {
    // Initial mock data based on the dashboard hotspots / zones
    _currentLocations = [
      LiveVehicleLocation(
        vehicleId: 'V-101',
        registrationNumber: 'WP-1234',
        routeId: 'RT-A1',
        zone: 'Zone A',
        location: const LatLng(6.9271, 79.8612), // near Colombo 
        status: VehicleStatus.onRoute,
        lastUpdated: DateTime.now(),
        driverName: 'Saman Kumara',
        completionPercentage: 45.0,
      ),
      LiveVehicleLocation(
        vehicleId: 'V-102',
        registrationNumber: 'WP-5678',
        routeId: 'RT-B2',
        zone: 'Zone B',
        location: const LatLng(6.9285, 79.8650),
        status: VehicleStatus.delayed,
        lastUpdated: DateTime.now(),
        driverName: 'Nuwan Perera',
        completionPercentage: 32.5,
      ),
      LiveVehicleLocation(
        vehicleId: 'V-103',
        registrationNumber: 'WP-9012',
        routeId: 'RT-C1',
        zone: 'Zone C',
        location: const LatLng(6.9250, 79.8630),
        status: VehicleStatus.onRoute,
        lastUpdated: DateTime.now(),
        driverName: 'Kamal Silva',
        completionPercentage: 78.0,
      ),
      LiveVehicleLocation(
        vehicleId: 'V-104',
        registrationNumber: 'WP-3456',
        routeId: 'RT-D4',
        zone: 'Zone D',
        location: const LatLng(6.9310, 79.8690),
        status: VehicleStatus.stopped,
        lastUpdated: DateTime.now(),
        driverName: 'Ruwan Fernando',
        completionPercentage: 12.0,
      ),
    ];
    _locationController.add(_currentLocations);
  }

  void _startSimulation() {
    // Simulate real-time updates every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _currentLocations = _currentLocations.map((loc) {
        if (loc.status == VehicleStatus.stopped) {
          return loc.copyWith(lastUpdated: DateTime.now());
        }

        // Simulate small movement
        final double latOffset = (_random.nextDouble() - 0.5) * 0.0005;
        final double lngOffset = (_random.nextDouble() - 0.5) * 0.0005;
        
        // Randomly change status occasionally
        VehicleStatus newStatus = loc.status;
        if (_random.nextDouble() < 0.05) {
          if (loc.status == VehicleStatus.onRoute) {
            newStatus = VehicleStatus.delayed;
          } else if (loc.status == VehicleStatus.delayed) {
            newStatus = VehicleStatus.onRoute;
          }
        }

        return loc.copyWith(
          location: LatLng(
            loc.location.latitude + latOffset,
            loc.location.longitude + lngOffset,
          ),
          status: newStatus,
          lastUpdated: DateTime.now(),
        );
      }).toList();

      _locationController.add(_currentLocations);
    });
  }

  void dispose() {
    _timer?.cancel();
    _locationController.close();
  }
}
