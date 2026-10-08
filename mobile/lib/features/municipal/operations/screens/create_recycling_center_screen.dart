import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/features/municipal/theme/municipal_colors.dart';
import 'package:mobile/features/recycling/models/material_item.dart';
import 'package:mobile/features/recycling/models/recycling_center.dart';
import 'package:mobile/features/recycling/services/recycling_service.dart';

class CreateRecyclingCenterScreen extends StatefulWidget {
  const CreateRecyclingCenterScreen({super.key});

  @override
  State<CreateRecyclingCenterScreen> createState() => _CreateRecyclingCenterScreenState();
}

class _CreateRecyclingCenterScreenState extends State<CreateRecyclingCenterScreen> {
  final _recyclingService = RecyclingService();
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _hoursController = TextEditingController(text: 'Mon - Sat: 8:00 AM - 5:30 PM');
  final _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();

  final _mapController = MapController();
  LatLng _selectedLocation = const LatLng(6.9271, 79.8612);

  List<MaterialItem> _materialsList = [];
  final Set<String> _selectedMaterials = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      final materials = await _recyclingService.fetchAllMaterials();
      setState(() {
        _materialsList = materials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading materials: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form Error: state is null')));
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (*)'), backgroundColor: Colors.red),
      );
      if (_nameController.text.trim().isEmpty) { _nameFocus.requestFocus(); return; }
      if (_cityController.text.trim().isEmpty) { _cityFocus.requestFocus(); return; }
      if (_addressController.text.trim().isEmpty) { _addressFocus.requestFocus(); return; }
      if (_phoneController.text.trim().isEmpty) { _phoneFocus.requestFocus(); return; }
      if (_emailController.text.trim().isEmpty) { _emailFocus.requestFocus(); return; }
      return;
    }

    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final officerEmail = _emailController.text.trim();

    setState(() => _isSubmitting = true);

    final newCenter = RecyclingCenter(
      id: '',
      officerEmail: officerEmail,
      name: name,
      address: address,
      city: city,
      
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      contactNumber: phone,
      email: officerEmail,
      operatingHours: _hoursController.text.trim().isNotEmpty
          ? _hoursController.text.trim()
          : 'Mon - Sat: 8:00 AM - 5:30 PM',
      isOpen: true,
      acceptedMaterials: _selectedMaterials.toList(),
      unsupportedMaterials: _materialsList
          .map((m) => m.name)
          .where((m) => !_selectedMaterials.contains(m))
          .toList(),
      notes: _notesController.text.trim(),
    );

    try {
      final created = await _recyclingService.createCenter(newCenter);
      if (!mounted) return;
      Navigator.pop(context, true);
      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recycling center "\" registered successfully!'),
            backgroundColor: MunicipalColors.secondaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create center: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      validator: isRequired ? (val) {
        if (val == null || val.trim().isEmpty) return 'Required';
        return null;
      } : null,
      focusNode: focusNode,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: MunicipalColors.secondaryGreen, size: 20),
        labelStyle: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 13),
        filled: true,
        fillColor: MunicipalColors.primaryBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.border),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MunicipalColors.secondaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Recycling Center', style: TextStyle(color: MunicipalColors.darkGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: MunicipalColors.darkGreen),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                const Text('Location Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
                const SizedBox(height: 8),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation,
                          initialZoom: 7.0,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _selectedLocation = point;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.ecomate.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text('Tap map to set location', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('General Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
                const SizedBox(height: 16),
                _buildFormField(_nameController, 'Center Name *', Icons.storefront, isRequired: true, focusNode: _nameFocus),
                const SizedBox(height: 12),
                _buildFormField(_cityController, 'City / Municipal Ward *', Icons.location_city_rounded, isRequired: true, focusNode: _cityFocus),
                const SizedBox(height: 12),
                _buildFormField(_addressController, 'Full Street Address *', Icons.location_on_outlined, isRequired: true, focusNode: _addressFocus),
                const SizedBox(height: 12),
                _buildFormField(_phoneController, 'Contact Phone *', Icons.phone_outlined, keyboardType: TextInputType.phone, isRequired: true, focusNode: _phoneFocus),
                const SizedBox(height: 12),
                _buildFormField(_emailController, 'Officer Login Email (e.g. officer@gmail.com) *', Icons.badge_outlined, keyboardType: TextInputType.emailAddress, isRequired: true, focusNode: _emailFocus),
                const SizedBox(height: 12),
                _buildFormField(_hoursController, 'Operating Hours', Icons.access_time_rounded),
                const SizedBox(height: 12),
                _buildFormField(_notesController, 'Notes / Instructions', Icons.notes_outlined, maxLines: 2),
                const SizedBox(height: 24),
                const Text('Accepted Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3.5,
                  ),
                  itemCount: _materialsList.length,
                  itemBuilder: (context, index) {
                    final material = _materialsList[index];
                    final isSelected = _selectedMaterials.contains(material.name);
                    return FilterChip(
                      label: Text(material.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedMaterials.add(material.name);
                          } else {
                            _selectedMaterials.remove(material.name);
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
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? MunicipalColors.secondaryGreen : MunicipalColors.border,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MunicipalColors.secondaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Recycling Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}











