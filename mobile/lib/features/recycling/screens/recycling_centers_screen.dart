import '../theme/recycling_colors.dart';
import 'package:flutter/material.dart';
import '../models/recycling_center.dart';
import '../services/recycling_service.dart';
import 'Center_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RecyclingCentersScreen extends StatefulWidget {
  const RecyclingCentersScreen({super.key});

  @override
  State<RecyclingCentersScreen> createState() => _RecyclingCentersScreenState();
}

class _RecyclingCentersScreenState extends State<RecyclingCentersScreen> {
  final RecyclingService _recyclingService = RecyclingService();
  final TextEditingController _searchController = TextEditingController();

  List<RecyclingCenter> _displayedCenters = [];
  String _selectedMaterial = 'All';
  bool _isLoading = false;
  Position? _userPosition;

  final List<String> _materialOptions = [
    'All',
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'E-Waste',
    'Organic',
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchCenters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
        _fetchCenters(); // re-sort based on distance
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _fetchCenters() async {
    setState(() => _isLoading = true);
    try {
      final centers = await _recyclingService.fetchRecyclingCenters(
        query: _searchController.text,
        materialFilter: _selectedMaterial,
      );
      
      if (_userPosition != null) {
        centers.sort((a, b) {
          final distA = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, a.latitude, a.longitude);
          final distB = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
      }
      
      if (mounted) {
        setState(() => _displayedCenters = centers);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDistance(double? distanceMeters) {
    if (distanceMeters == null) return 'Distance unknown';
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m away';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: RecyclingColors.deepForestGreen, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Nearby Centers',
            style: TextStyle(
              color: RecyclingColors.deepForestGreen,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: RecyclingColors.forestGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: RecyclingColors.forestGreen,
            tabs: [
              Tab(icon: Icon(Icons.list_rounded), text: 'List'),
              Tab(icon: Icon(Icons.map_rounded), text: 'Map'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search and Filters
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _fetchCenters(),
                    style: const TextStyle(color: Color(0xFF2D3748)),
                    decoration: InputDecoration(
                      hintText: 'Search centers...',
                      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: RecyclingColors.forestGreen),
                      filled: true,
                      fillColor: RecyclingColors.offWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: RecyclingColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: RecyclingColors.forestGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _materialOptions.map((mat) {
                        final isSelected = _selectedMaterial == mat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(mat),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedMaterial = mat);
                              _fetchCenters();
                            },
                            selectedColor: RecyclingColors.deepForestGreen,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : RecyclingColors.earthyBrown,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            // Tabs Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: RecyclingColors.deepForestGreen))
                  : TabBarView(
                      physics: const NeverScrollableScrollPhysics(), // Map needs its own gestures
                      children: [
                        _buildListView(),
                        _buildMapView(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_displayedCenters.isEmpty) {
      return const Center(child: Text('No centers found.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _displayedCenters.length,
      itemBuilder: (context, index) {
        final center = _displayedCenters[index];
        return _buildCenterCard(center);
      },
    );
  }

  Widget _buildMapView() {
    if (_displayedCenters.isEmpty && _userPosition == null) {
      return const Center(child: Text('No map data.'));
    }
    
    final initialCenter = _userPosition != null 
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : (_displayedCenters.isNotEmpty ? LatLng(_displayedCenters.first.latitude, _displayedCenters.first.longitude) : const LatLng(6.9271, 79.8612));
        
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ecomate.app',
        ),
        MarkerLayer(
          markers: [
            if (_userPosition != null)
              Marker(
                point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
              ),
            ..._displayedCenters.map((c) => Marker(
                  point: LatLng(c.latitude, c.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CenterDetailScreen(center: c)));
                    },
                    child: Icon(
                      Icons.location_on,
                      color: c.isOpen ? RecyclingColors.forestGreen : Colors.red,
                      size: 30,
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildCenterCard(RecyclingCenter center) {
    double? dist;
    if (_userPosition != null) {
      dist = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, center.latitude, center.longitude);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CenterDetailScreen(center: center))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      center.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: RecyclingColors.deepForestGreen),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: center.isOpen ? const Color(0xFFE5E9DD) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      center.isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(color: center.isOpen ? RecyclingColors.forestGreen : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(center.address, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(_formatDistance(dist), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      center.operatingHours,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

