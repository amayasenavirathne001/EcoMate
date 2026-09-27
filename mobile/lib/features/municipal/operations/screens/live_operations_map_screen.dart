import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../theme/municipal_colors.dart';
import '../models/live_vehicle_location.dart';
import '../services/live_map_service.dart';
import '../../../../services/waste_report_service.dart';

class LiveOperationsMapScreen extends StatefulWidget {
  final int initialTab;
  const LiveOperationsMapScreen({super.key, this.initialTab = 0});

  @override
  State<LiveOperationsMapScreen> createState() => _LiveOperationsMapScreenState();
}

class _LiveOperationsMapScreenState extends State<LiveOperationsMapScreen> {
  late int _selectedTab;

  // Live Operations State
  final LiveMapService _liveMapService = LiveMapService();
  final MapController _mapController = MapController();
  
  List<LiveVehicleLocation> _locations = [];
  StreamSubscription? _locationSubscription;
  
  // Live Operations Filters
  String _selectedZone = 'All';
  String _selectedStatus = 'All';
  final List<String> _zones = ['All', 'Zone A', 'Zone B', 'Zone C', 'Zone D'];
  final List<String> _statuses = ['All', 'On Route', 'Delayed', 'Stopped'];
  LiveVehicleLocation? _selectedVehicle;

  // Hotspots State
  final WasteReportService _reportService = WasteReportService();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoadingReports = false;

  // Hotspots Filters
  String _hsTimeFilter = 'All Time';
  String _hsPriorityFilter = 'All';
  String _hsStatusFilter = 'Unresolved';
  final List<String> _timeFilters = ['All Time', 'This Week', 'This Month'];
  final List<String> _priorityFilters = ['All', 'HIGH', 'MEDIUM', 'LOW'];
  final List<String> _statusFilters = ['Unresolved', 'All Statuses', 'Resolved'];

  // Map state
  final LatLng _initialCenter = const LatLng(6.9271, 79.8612); // Colombo
  double _currentZoom = 13.0;
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    
    // Setup Live Operations
    _locations = _liveMapService.getCurrentLocations();
    _locationSubscription = _liveMapService.locationStream.listen((locations) {
      if (mounted) {
        setState(() {
          _locations = locations;
          if (_selectedTab == 0) {
            _lastUpdated = DateTime.now();
          }
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

    // Setup Hotspots
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    if (!mounted) return;
    setState(() => _isLoadingReports = true);
    try {
      final reports = await _reportService.getAdminReports();
      if (mounted) {
        setState(() {
          _reports = reports;
        });
      }
    } catch (e) {
      debugPrint('Error loading reports for hotspots: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingReports = false);
        if (_selectedTab == 1) {
          _lastUpdated = DateTime.now();
        }
      }
    }
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

  List<Map<String, dynamic>> get _filteredHotspots {
    return _reports.where((r) {
      if (r['latitude'] == null || r['longitude'] == null) return false;

      // Status Filter
      final status = r['status']?.toString() ?? 'SUBMITTED';
      if (_hsStatusFilter == 'Unresolved' && (status == 'RESOLVED' || status == 'REJECTED')) return false;
      if (_hsStatusFilter == 'Resolved' && status != 'RESOLVED') return false;

      // Priority Filter
      final priority = r['priority']?.toString() ?? 'MEDIUM';
      if (_hsPriorityFilter != 'All' && priority != _hsPriorityFilter) return false;

      // Time Filter
      if (_hsTimeFilter != 'All Time' && r['createdAt'] != null) {
        final createdAt = DateTime.tryParse(r['createdAt'].toString());
        if (createdAt != null) {
          final now = DateTime.now();
          if (_hsTimeFilter == 'This Week' && now.difference(createdAt).inDays > 7) return false;
          if (_hsTimeFilter == 'This Month' && now.difference(createdAt).inDays > 30) return false;
        }
      }

      return true;
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

  void _showVehicleDetails(LiveVehicleLocation vehicle) {
    setState(() => _selectedVehicle = vehicle);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVehicleDetailsSheet(vehicle),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedVehicle = null);
    });
  }

  void _showHotspotDetails(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHotspotDetailsSheet(report),
    );
  }

  Widget _buildHotspotDetailsSheet(Map<String, dynamic> report) {
    final status = report['status']?.toString() ?? 'SUBMITTED';
    final priority = report['priority']?.toString() ?? 'MEDIUM';
    final dateStr = report['createdAt']?.toString();
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final formattedDate = date != null ? DateFormat('MMM d, y, h:mm a').format(date) : 'Unknown';

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
              Expanded(
                child: Text(
                  report['issueType']?.toString() ?? 'Waste Issue',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MunicipalColors.primaryText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getHotspotColor(priority).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$priority Priority',
                  style: TextStyle(
                    color: _getHotspotColor(priority),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.pin_drop_rounded, 'Location', report['location']?.toString() ?? 'Unknown location'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.category_rounded, 'Waste Type', report['wasteCategory']?.toString() ?? 'Unknown'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.calendar_today_rounded, 'Reported On', formattedDate),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.info_outline_rounded, 'Current Status', status.replaceAll('_', ' ')),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: MunicipalColors.secondaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
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
                  color: _getStatusColor(vehicle.status).withValues(alpha: 0.15),
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
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }

  Widget _buildTabHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = 0;
                    _lastUpdated = DateTime.now();
                  });
                },
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
                      fontSize: 14,
                      fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w600,
                      color: _selectedTab == 0 ? MunicipalColors.secondaryGreen : MunicipalColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = 1;
                    _lastUpdated = DateTime.now();
                  });
                  if (_reports.isEmpty) {
                    _fetchReports();
                  }
                },
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
                      fontSize: 14,
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
    );
  }

  Widget _buildHotspotSummary() {
    final filtered = _filteredHotspots;
    final total = filtered.length;
    final active = filtered.where((r) => r['status'] != 'RESOLVED' && r['status'] != 'REJECTED').length;
    final highPriority = filtered.where((r) => r['priority'] == 'HIGH').length;

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: [
          _buildSummaryChip('Total', total.toString(), MunicipalColors.primaryText),
          const SizedBox(width: 8),
          _buildSummaryChip('Active', active.toString(), MunicipalColors.warning),
          const SizedBox(width: 8),
          _buildSummaryChip('High Priority', highPriority.toString(), MunicipalColors.error),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: MunicipalColors.secondaryText, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatTime = "${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}:${_lastUpdated.second.toString().padLeft(2, '0')}";
    final isLive = _selectedTab == 0;

    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Map Overview',
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
              child: GestureDetector(
                onTap: isLive ? null : _fetchReports,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive ? MunicipalColors.surface : MunicipalColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (_isLoadingReports)
                        const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: MunicipalColors.warning),
                        )
                      else
                        Icon(isLive ? Icons.sync_rounded : Icons.refresh_rounded, size: 14, color: isLive ? MunicipalColors.secondaryGreen : MunicipalColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        isLive ? 'Live • $formatTime' : 'Sync • $formatTime',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLive ? MunicipalColors.secondaryGreen : MunicipalColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabHeader(),
          Expanded(
            child: Stack(
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
                    if (isLive)
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
                      )
                    else
                      MarkerLayer(
                        markers: _filteredHotspots.map((report) {
                          final lat = double.tryParse(report['latitude'].toString()) ?? 0.0;
                          final lng = double.tryParse(report['longitude'].toString()) ?? 0.0;
                          final priority = report['priority']?.toString() ?? 'MEDIUM';
                          final color = _getHotspotColor(priority);

                          return Marker(
                            width: 50.0,
                            height: 50.0,
                            point: LatLng(lat, lng),
                            child: GestureDetector(
                              onTap: () => _showHotspotDetails(report),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withOpacity(0.3),
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
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
                  top: isLive ? 16 : 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (!isLive) _buildHotspotSummary(),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: isLive ? [
                            _buildDropdownFilter(
                              icon: Icons.map_rounded,
                              value: _selectedZone,
                              items: _zones,
                              color: MunicipalColors.secondaryGreen,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedZone = val);
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildDropdownFilter(
                              icon: Icons.info_outline_rounded,
                              value: _selectedStatus,
                              items: _statuses,
                              color: MunicipalColors.secondaryGreen,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                          ] : [
                            _buildDropdownFilter(
                              icon: Icons.calendar_today_rounded,
                              value: _hsTimeFilter,
                              items: _timeFilters,
                              color: MunicipalColors.warning,
                              onChanged: (val) {
                                if (val != null) setState(() => _hsTimeFilter = val);
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildDropdownFilter(
                              icon: Icons.flag_rounded,
                              value: _hsPriorityFilter,
                              items: _priorityFilters,
                              color: MunicipalColors.warning,
                              onChanged: (val) {
                                if (val != null) setState(() => _hsPriorityFilter = val);
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildDropdownFilter(
                              icon: Icons.filter_alt_rounded,
                              value: _hsStatusFilter,
                              items: _statusFilters,
                              color: MunicipalColors.warning,
                              onChanged: (val) {
                                if (val != null) setState(() => _hsStatusFilter = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required IconData icon,
    required String value,
    required List<String> items,
    required Color color,
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
          Icon(icon, size: 16, color: color),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
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
