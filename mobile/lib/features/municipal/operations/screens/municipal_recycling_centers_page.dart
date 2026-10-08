import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../../../recycling/models/recycling_center.dart';
import '../../../recycling/models/material_item.dart';
import '../../../recycling/services/recycling_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MunicipalRecyclingCentersPage extends StatefulWidget {
  const MunicipalRecyclingCentersPage({super.key});

  @override
  State<MunicipalRecyclingCentersPage> createState() => _MunicipalRecyclingCentersPageState();
}

class _MunicipalRecyclingCentersPageState extends State<MunicipalRecyclingCentersPage> {
  final RecyclingService _recyclingService = RecyclingService();
  final TextEditingController _searchController = TextEditingController();
  List<MaterialItem> _materialsList = [];

  List<RecyclingCenter> _allCenters = [];
  List<RecyclingCenter> _filteredCenters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCenters() async {
    setState(() => _isLoading = true);
    final list = await _recyclingService.fetchRecyclingCenters();
    final mats = await _recyclingService.fetchAllMaterials();
    if (mounted) {
      setState(() {
        _allCenters = list;
        _materialsList = mats;
        _filterCenters();
        _isLoading = false;
      });
    }
  }

  void _filterCenters() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredCenters = List.from(_allCenters);
    } else {
      _filteredCenters = _allCenters.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.city.toLowerCase().contains(query) ||
            c.address.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _openAddCenterDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final hoursController = TextEditingController(text: 'Mon - Sat: 8:00 AM - 5:30 PM');
    final notesController = TextEditingController();

    final availableMaterials = _materialsList.map((m) => m.name).toSet().toList();
    final Set<String> selectedMaterials = {};

    bool isSubmitting = false;
    bool autovalidate = false;
    LatLng? selectedLocation; 
    
    final _formKey = GlobalKey<FormState>();
    final _scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: autovalidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.add_business_rounded, color: MunicipalColors.darkGreen),
                              SizedBox(width: 10),
                              Text(
                                'Add Recycling Center',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: MunicipalColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Select Location on Map *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: autovalidate && selectedLocation == null ? MunicipalColors.error : MunicipalColors.border,
                            width: autovalidate && selectedLocation == null ? 1.5 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: const LatLng(6.9271, 79.8612),
                              initialZoom: 10.0,
                              onTap: (tapPosition, point) {
                                setModalState(() {
                                  selectedLocation = point;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.ecomate.app',
                              ),
                              if (selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: selectedLocation!,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (autovalidate && selectedLocation == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 12),
                          child: Text('Please select a location on the map', style: TextStyle(color: MunicipalColors.error, fontSize: 12)),
                        )
                      else if (selectedLocation == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Tap on the map to pin the center location', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      const SizedBox(height: 16),
_buildFormField(nameController, 'Center Name *', Icons.storefront, isRequired: true),
                      const SizedBox(height: 12),
                      _buildFormField(cityController, 'City / Municipal Ward *', Icons.location_city_rounded, isRequired: true),
                      const SizedBox(height: 12),
                      _buildFormField(addressController, 'Full Street Address *', Icons.location_on_outlined, isRequired: true),
                      const SizedBox(height: 12),
                      _buildFormField(phoneController, 'Contact Phone *', Icons.phone_outlined, keyboardType: TextInputType.phone, isRequired: true),
                      const SizedBox(height: 12),
                      _buildFormField(emailController, 'Officer Login Email (e.g. officer@gmail.com) *', Icons.badge_outlined, keyboardType: TextInputType.emailAddress, isRequired: true),
                      const SizedBox(height: 12),
                      _buildFormField(hoursController, 'Operating Hours', Icons.access_time_rounded),
                      const SizedBox(height: 12),
                      _buildFormField(notesController, 'Notes / Instructions', Icons.notes_outlined, maxLines: 2),
                      const SizedBox(height: 16),
                      const Text(
                        'Accepted Materials',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MunicipalColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // 2-by-2 Grid for Accepted Materials
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: availableMaterials.length,
                        itemBuilder: (context, index) {
                          final mat = availableMaterials[index];
                          final isSelected = selectedMaterials.contains(mat);
                          return FilterChip(
                            label: Text(mat, overflow: TextOverflow.ellipsis),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  selectedMaterials.add(mat);
                                } else {
                                  selectedMaterials.remove(mat);
                                }
                              });
                            },
                            selectedColor: MunicipalColors.secondaryGreen.withValues(alpha: 0.15),
                            checkmarkColor: MunicipalColors.secondaryGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? MunicipalColors.darkGreen : MunicipalColors.secondaryText,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? MunicipalColors.secondaryGreen : MunicipalColors.border,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate() || selectedLocation == null) {
                                  setModalState(() => autovalidate = true);
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please correct the highlighted errors'),
                                      backgroundColor: MunicipalColors.error,
                                    ),
                                  );
                                  return;
                                }

                                final name = nameController.text.trim();
                                final city = cityController.text.trim();
                                final address = addressController.text.trim();
                                final phone = phoneController.text.trim();
                                final officerEmail = emailController.text.trim();

                                setModalState(() => isSubmitting = true);

                                final newCenter = RecyclingCenter(
                                  id: '',
                                  officerEmail: officerEmail,
                                  name: name,
                                  address: address,
                                  city: city,
                                  latitude: selectedLocation!.latitude,
                                  longitude: selectedLocation!.longitude,
                                  contactNumber: phone,
                                  email: officerEmail,
                                  operatingHours: hoursController.text.trim().isNotEmpty
                                      ? hoursController.text.trim()
                                      : 'Mon - Sat: 8:00 AM - 5:30 PM',
                                  isOpen: true,
                                  acceptedMaterials: selectedMaterials.toList(),
                                  unsupportedMaterials: availableMaterials
                                      .where((m) => !selectedMaterials.contains(m))
                                      .toList(),
                                  notes: notesController.text.trim(),
                                );

                                final created = await _recyclingService.createCenter(newCenter);

                                if (!context.mounted) return;
                                Navigator.pop(context);

                                if (created != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Recycling center "${created.name}" registered successfully!'),
                                      backgroundColor: MunicipalColors.secondaryGreen,
                                    ),
                                  );
                                  _loadCenters();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MunicipalColors.secondaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Save Recycling Center',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              if (keyboardType == TextInputType.emailAddress && !value.contains('@')) {
                return 'Enter a valid email address';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: MunicipalColors.secondaryGreen, size: 20),
        labelStyle: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 13),
        filled: true,
        fillColor: MunicipalColors.primaryBg,
        errorStyle: const TextStyle(color: MunicipalColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.secondaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: MunicipalColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: MunicipalColors.darkGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const TabBar(
          labelColor: MunicipalColors.secondaryGreen,
          unselectedLabelColor: MunicipalColors.mutedText,
          indicatorColor: MunicipalColors.secondaryGreen,
          tabs: [
            Tab(icon: Icon(Icons.list_rounded), text: 'List'),
            Tab(icon: Icon(Icons.map_rounded), text: 'Map'),
          ],
        ),
        title: const Text(
          'Recycling Centers',
          style: TextStyle(
            color: MunicipalColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCenterDialog,
        backgroundColor: MunicipalColors.secondaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Center', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Summary Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {
                        _filterCenters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by center name, city, address...',
                      hintStyle: const TextStyle(color: MunicipalColors.mutedText, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: MunicipalColors.secondaryGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: MunicipalColors.secondaryText),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filterCenters();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: MunicipalColors.primaryBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: MunicipalColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: MunicipalColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: MunicipalColors.secondaryGreen, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Centers: ${_filteredCenters.length}',
                        style: const TextStyle(
                          color: MunicipalColors.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: MunicipalColors.border),

            // Centers List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen),
                    )
                  : TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // LIST VIEW
                        _filteredCenters.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      size: 56,
                                      color: MunicipalColors.mutedText.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No recycling centers found',
                                      style: TextStyle(
                                        color: MunicipalColors.secondaryText,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _openAddCenterDialog,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Add Your First Center'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: MunicipalColors.secondaryGreen,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                                itemCount: _filteredCenters.length,
                                itemBuilder: (context, index) {
                                  final center = _filteredCenters[index];
                                  return _buildCenterCard(center);
                                },
                              ),
                        
                        // MAP VIEW
                        _filteredCenters.isEmpty
                            ? const Center(child: Text('No centers to display on map'))
                            : FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(_filteredCenters.first.latitude, _filteredCenters.first.longitude),
                                  initialZoom: 12,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.ecomate.app',
                                  ),
                                  MarkerLayer(
                                    markers: _filteredCenters.map((c) => Marker(
                                      point: LatLng(c.latitude, c.longitude),
                                      width: 40,
                                      height: 40,
                                      child: GestureDetector(
                                          onTap: () {
                                              // Can do something
                                          },
                                          child: const Icon(
                                            Icons.location_city_rounded,
                                            color: MunicipalColors.secondaryGreen,
                                            size: 30,
                                          )
                                      ),
                                    )).toList(),
                                  ),
                                ],
                              ),
                      ],
                    ),
            ),

          ],
        ),
      ),
    ));

  }

  Widget _buildCenterCard(RecyclingCenter center) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MunicipalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: MunicipalColors.secondaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.recycling_rounded, color: MunicipalColors.secondaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MunicipalColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_city_rounded, size: 14, color: MunicipalColors.secondaryText),
                          const SizedBox(width: 4),
                          Text(
                            center.city,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MunicipalColors.secondaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: center.isOpen
                        ? MunicipalColors.success.withValues(alpha: 0.12)
                        : MunicipalColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    center.isOpen ? 'OPEN' : 'CLOSED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: center.isOpen ? MunicipalColors.darkGreen : MunicipalColors.error,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: MunicipalColors.error, size: 20),
                  tooltip: 'Delete Center',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Center'),
                        content: Text('Are you sure you want to delete "${center.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete', style: TextStyle(color: MunicipalColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _recyclingService.deleteCenter(center.id);
                      _loadCenters();
                    }
                  },
                ),
              ],
            ),

            if (center.officerEmail != null && center.officerEmail!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 14, color: MunicipalColors.secondaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    'Officer: ${center.officerEmail}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MunicipalColors.secondaryGreen),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: MunicipalColors.border),
            const SizedBox(height: 10),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: MunicipalColors.secondaryText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    center.address,
                    style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Contact Phone
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: MunicipalColors.secondaryText),
                const SizedBox(width: 6),
                Text(
                  center.contactNumber,
                  style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Operating Hours
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: MunicipalColors.secondaryText),
                const SizedBox(width: 6),
                Text(
                  center.operatingHours,
                  style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
                ),
              ],
            ),

            if (center.acceptedMaterials.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: center.acceptedMaterials.take(4).map((mat) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: MunicipalColors.primaryBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: MunicipalColors.border),
                    ),
                    child: Text(
                      mat,
                      style: const TextStyle(fontSize: 11, color: MunicipalColors.darkGreen, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

















