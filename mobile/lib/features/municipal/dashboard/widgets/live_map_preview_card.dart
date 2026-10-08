import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/municipal_colors.dart';
import '../../operations/screens/live_operations_map_screen.dart';
import '../../operations/models/live_vehicle_location.dart';
import '../../operations/services/live_map_service.dart';
import '../../../../services/waste_report_service.dart';

class LiveMapPreviewCard extends StatefulWidget {
  const LiveMapPreviewCard({super.key});

  @override
  State<LiveMapPreviewCard> createState() => _LiveMapPreviewCardState();
}

class _LiveMapPreviewCardState extends State<LiveMapPreviewCard> {
  int _selectedTab = 0; // 0 for Live Operations, 1 for Hotspots

  final LiveMapService _liveMapService = LiveMapService();
  final WasteReportService _reportService = WasteReportService();
  
  List<LiveVehicleLocation> _locations = [];
  StreamSubscription? _locationSubscription;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _locations = _liveMapService.getCurrentLocations();
    _locationSubscription = _liveMapService.locationStream.listen((locations) {
      if (mounted) {
        setState(() {
          _locations = locations;
        });
      }
    });
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    if (!mounted) return;
    try {
      final reports = await _reportService.getAdminReports();
      if (mounted) {
        setState(() {
          _reports = reports;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredHotspots {
    return _reports.where((r) {
      if (r['latitude'] == null || r['longitude'] == null) return false;
      final status = r['status']?.toString() ?? 'SUBMITTED';
      if (status == 'RESOLVED' || status == 'REJECTED') return false; 
      return true;
    }).toList();
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

  Color _getHotspotColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return MunicipalColors.error; // Red
      case 'MEDIUM':
        return MunicipalColors.warning; // Orange
      case 'LOW':
        return MunicipalColors.info; // Blue
      default:
        return MunicipalColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedTab == 0 ? Icons.satellite_alt_rounded : Icons.local_fire_department_rounded, 
                      color: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.warning
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Map Overview',
                      style: TextStyle(
                        color: MunicipalColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 ? MunicipalColors.surface : MunicipalColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        _selectedTab == 0 ? 'Live' : 'Hotspots',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 0
                              ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Live Operations',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w600,
                            color: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 1
                              ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Hotspots',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w600,
                            color: _selectedTab == 1 ? MunicipalColors.warning : MunicipalColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Map Preview Area
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LiveOperationsMapScreen(initialTab: _selectedTab)),
              );
            },
            child: Container(
              height: 160,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE2E8F0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AbsorbPointer(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(6.9271, 79.8612), // Colombo
                      initialZoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ecomate.mobile',
                      ),
                      if (_selectedTab == 0)
                        MarkerLayer(
                          markers: _locations.map((loc) {
                            return Marker(
                              width: 30.0,
                              height: 30.0,
                              point: loc.location,
                              child: Icon(
                                Icons.local_shipping_rounded,
                                color: _getStatusColor(loc.status),
                                size: 24,
                              ),
                            );
                          }).toList(),
                        )
                      else
                        MarkerLayer(
                          markers: _filteredHotspots.map((report) {
                            final lat = double.tryParse(report['latitude'].toString()) ?? 0.0;
                            final lng = double.tryParse(report['longitude'].toString()) ?? 0.0;
                            final priority = report['priority']?.toString() ?? 'MEDIUM';
                            final color = _getHotspotColor(priority);

                            return Marker(
                              width: 30.0,
                              height: 30.0,
                              point: LatLng(lat, lng),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Footer / View Full Map button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LiveOperationsMapScreen(initialTab: _selectedTab)),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.warning,
                side: BorderSide(color: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.warning),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'View Full Map',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
