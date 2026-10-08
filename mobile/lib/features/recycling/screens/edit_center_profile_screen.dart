import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/recycling_center.dart';
import '../services/recycling_service.dart';
import '../theme/recycling_colors.dart';

class EditCenterProfileScreen extends StatefulWidget {
  final RecyclingCenter initialCenter;

  const EditCenterProfileScreen({Key? key, required this.initialCenter}) : super(key: key);

  @override
  State<EditCenterProfileScreen> createState() => _EditCenterProfileScreenState();
}

class _EditCenterProfileScreenState extends State<EditCenterProfileScreen> {
  final RecyclingService _recyclingService = RecyclingService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _hoursController;
  late TextEditingController _notesController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  LatLng _selectedLocation = const LatLng(6.9271, 79.8612); // Default Colombo
  bool _isSubmitting = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialCenter.name);
    _addressController = TextEditingController(text: widget.initialCenter.address);
    _cityController = TextEditingController(text: widget.initialCenter.city);
    _phoneController = TextEditingController(text: widget.initialCenter.contactNumber);
    _emailController = TextEditingController(text: widget.initialCenter.email);
    _hoursController = TextEditingController(text: widget.initialCenter.operatingHours);
    _notesController = TextEditingController(text: widget.initialCenter.notes);

    if (widget.initialCenter.latitude != null && widget.initialCenter.longitude != null) {
      _selectedLocation = LatLng(widget.initialCenter.latitude!, widget.initialCenter.longitude!);
    }
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
    _nameFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      }
      return;
    } 

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Getting current location...')));
    }

    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(_selectedLocation, 15.0);
  }

  Future<void> _submit() async {
    if (_formKey.currentState == null) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (*)'), backgroundColor: Colors.red),
      );
      if (_nameController.text.trim().isEmpty) { _nameFocus.requestFocus(); return; }
      if (_addressController.text.trim().isEmpty) { _addressFocus.requestFocus(); return; }
      if (_cityController.text.trim().isEmpty) { _cityFocus.requestFocus(); return; }
      if (_phoneController.text.trim().isEmpty) { _phoneFocus.requestFocus(); return; }
      if (_emailController.text.trim().isEmpty) { _emailFocus.requestFocus(); return; }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updated = widget.initialCenter.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        contactNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        operatingHours: _hoursController.text.trim(),
        notes: _notesController.text.trim(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );

      await _recyclingService.saveOrUpdateCenter(updated);
      
      if (mounted) {
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
        prefixIcon: Icon(icon, color: RecyclingColors.primaryGreen, size: 20),
        labelStyle: const TextStyle(color: RecyclingColors.secondaryText, fontSize: 13),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RecyclingColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Center Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: RecyclingColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RecyclingColors.darkText)),
              const SizedBox(height: 16),
              _buildFormField(_nameController, 'Center Name *', Icons.storefront, isRequired: true, focusNode: _nameFocus),
              const SizedBox(height: 12),
              _buildFormField(_addressController, 'Street Address *', Icons.location_on_outlined, isRequired: true, focusNode: _addressFocus),
              const SizedBox(height: 12),
              _buildFormField(_cityController, 'City / District *', Icons.location_city_outlined, isRequired: true, focusNode: _cityFocus),
              const SizedBox(height: 12),
              _buildFormField(_phoneController, 'Contact Phone *', Icons.phone_outlined, keyboardType: TextInputType.phone, isRequired: true, focusNode: _phoneFocus),
              const SizedBox(height: 12),
              _buildFormField(_emailController, 'Official Email *', Icons.email_outlined, keyboardType: TextInputType.emailAddress, isRequired: true, focusNode: _emailFocus),
              const SizedBox(height: 12),
              _buildFormField(_hoursController, 'Operating Hours', Icons.access_time_outlined),
              const SizedBox(height: 12),
              _buildFormField(_notesController, 'Policies & Notes', Icons.notes_outlined, maxLines: 2),
              
              const SizedBox(height: 24),
              const Text('Center Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RecyclingColors.darkText)),
              const SizedBox(height: 8),
              const Text('Tap the map to set location manually, or use the button to get current GPS location.', style: TextStyle(fontSize: 13, color: RecyclingColors.secondaryText)),
              const SizedBox(height: 12),
              
              OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location, color: RecyclingColors.primaryGreen),
                label: const Text('Use Current GPS Location', style: TextStyle(color: RecyclingColors.primaryGreen)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: RecyclingColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 14.0,
                      onTap: (tapPosition, point) {
                        setState(() => _selectedLocation = point);
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
                ),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RecyclingColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}


