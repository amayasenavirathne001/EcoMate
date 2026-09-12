import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/municipal_colors.dart';
import '../models/live_vehicle_location.dart';
import '../services/live_map_service.dart';

class LiveOperationsMapScreen extends StatefulWidget {
  const LiveOperationsMapScreen({super.key});

  @override
  State<LiveOperationsMapScreen> createState() => _LiveOperationsMapScreenState();
}

class _LiveOperationsMapScreenState extends State<LiveOperationsMapScreen> {
  final LiveMapService _liveMapService = LiveMapService();
  final MapController _mapController = MapController();
  
  List<LiveVehicleLocation> _locations = [];
  StreamSubscription? _locationSubscription;
  
  // Filters
  String _selectedZone = 'All';
  String _selectedStatus = 'All';
  final List<String> _zones = ['All', 'Zone A', 'Zone B', 'Zone C', 'Zone D'];
  final List<String> _statuses = ['All', 'On Route', 'Delayed', 'Stopped'];

  // Map state
  final LatLng _initialCenter = const LatLng(6.9271, 79.8612); // Colombo
  double _currentZoom = 13.0;
  DateTime _lastUpdated = DateTime.now();
  LiveVehicleLocation? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _locations = _liveMapService.getCurrentLocations();
    
    _locationSubscription = _liveMapService.locationStream.listen((locations) {
      if (mounted) {
        setState(() {
          _locations = locations;
          _lastUpdated = DateTime.now();
          
          // Update selected vehicle reference if it exists
          if (_selectedVehicle != null) {
            try {
              _selectedVehicle = _locations.firstWhere(
                (v) => v.vehicleId == _selectedVehicle!.vehicleId,
              );
            } catch (e) {
              _selectedVehicle = null;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  List<LiveVehicleLocation> get _filteredLocations {
    return _locations.where((loc) {
      bool zoneMatch = _selectedZone == 'All' || loc.zone == _selectedZone;
      
      String statusStr = 'On Route';
      if (loc.status == VehicleStatus.delayed) statusStr = 'Delayed';
      if (loc.status == VehicleStatus.stopped) statusStr = 'Stopped';
      
      bool statusMatch = _selectedStatus == 'All' || statusStr == _selectedStatus;
      
      return zoneMatch && statusMatch;
    }).toList();
  }

  void _zoomIn() {
    _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _centerMap() {
    _currentZoom = 13.0;
    _mapController.move(_initialCenter, _currentZoom);
  }
  
  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.onRoute:
        return const Color(0xFF22C55E); // Green
      case VehicleStatus.delayed:
        return const Color(0xFFF59E0B); // Orange
      case VehicleStatus.stopped:
        return const Color(0xBEEF4444); // Red
    }
  }

  void _showVehicleDetails(LiveVehicleLocation vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
    });
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVehicleDetailsSheet(vehicle),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _selectedVehicle = null;
        });
      }
    });
  }

  Widget _buildVehicleDetailsSheet(LiveVehicleLocation vehicle) {
    String statusStr = 'On Route';
    if (vehicle.status == VehicleStatus.delayed) statusStr = 'Delayed';
    if (vehicle.status == VehicleStatus.stopped) statusStr = 'Stopped';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vehicle ${vehicle.vehicleId}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MunicipalColors.primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(vehicle.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusStr,
                  style: TextStyle(
                    color: _getStatusColor(vehicle.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.pin_drop_rounded, 'Route ID & Zone', '${vehicle.routeId} • ${vehicle.zone}'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.directions_car_rounded, 'Registration', vehicle.registrationNumber),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.person_rounded, 'Driver', vehicle.driverName),
          const SizedBox(height: 20),
          
          const Text(
            'Route Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MunicipalColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: vehicle.completionPercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: MunicipalColors.secondaryGreen,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${vehicle.completionPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MunicipalColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In real app, could navigate to full assignment details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MunicipalColors.secondaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Assignment Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MunicipalColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: MunicipalColors.secondaryGreen),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: MunicipalColors.secondaryText,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MunicipalColors.primaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatTime = "${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}:${_lastUpdated.second.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Live Operations Map',
          style: TextStyle(
            color: MunicipalColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: MunicipalColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MunicipalColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 14, color: MunicipalColors.secondaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Live • $formatTime',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MunicipalColors.secondaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecomate.mobile',
              ),
              MarkerLayer(
                markers: _filteredLocations.map((loc) {
                  return Marker(
                    width: 60.0,
                    height: 60.0,
                    point: loc.location,
                    child: GestureDetector(
                      onTap: () => _showVehicleDetails(loc),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: Text(
                              loc.vehicleId,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.local_shipping_rounded,
                            color: _getStatusColor(loc.status),
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Filters
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildDropdownFilter(
                    icon: Icons.map_rounded,
                    value: _selectedZone,
                    items: _zones,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedZone = val);
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildDropdownFilter(
                    icon: Icons.info_outline_rounded,
                    value: _selectedStatus,
                    items: _statuses,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Controls
          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapButton(
                  icon: Icons.my_location_rounded,
                  onPressed: _centerMap,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_rounded, color: MunicipalColors.primaryText),
                        onPressed: _zoomIn,
                      ),
                      Container(height: 1, width: 30, color: Colors.grey.shade200),
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, color: MunicipalColors.primaryText),
                        onPressed: _zoomOut,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MunicipalColors.secondaryGreen),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              style: const TextStyle(
                color: MunicipalColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: MunicipalColors.primaryText),
        onPressed: onPressed,
      ),
    );
  }
}
