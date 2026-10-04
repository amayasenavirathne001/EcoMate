import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/waste_report_service.dart';
import 'login_screen.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  static const _green = Color(0xFF08795E);
  static const _deepGreen = Color(0xFF064E3B);
  static const _background = Color(0xFFF4F8F4);
  static const _muted = Color(0xFF66756F);

  final _authService = AuthService();
  final _reportService = WasteReportService();
  Map<String, dynamic>? _profile;
  int _totalReports = 0;
  int _resolvedReports = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await _authService.getCurrentUser();
      if (profile == null) {
        throw Exception(
          'Could not load your profile. Check your connection and sign in again.',
        );
      }
      var reports = <Map<String, dynamic>>[];
      try {
        reports = await _reportService.getMyReports();
      } catch (_) {
        // Profile information remains available when report history is offline.
      }
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _totalReports = reports.length;
        _resolvedReports = reports
            .where(
              (report) =>
                  (report['status'] ?? '').toString().toUpperCase() ==
                  'RESOLVED',
            )
            .length;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _editDetails() async {
    final profile = _profile;
    if (profile == null) return;
    final values = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _EditProfileSheet(profile: profile),
        ),
    );
    if (values != null) await _saveProfile(values);
  }

  Future<void> _chooseProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from photos'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 75,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      final imageData =
          'data:${image.mimeType ?? 'image/jpeg'};base64,${base64Encode(bytes)}';
      if (imageData.length > 1_450_000) {
        _showMessage('Choose a smaller photo and try again.');
        return;
      }
      await _saveProfile({'profilePicUrl': imageData});
    } catch (error) {
      _showMessage('Could not select photo: $error');
    }
  }

  Future<void> _saveProfile(Map<String, String> changes) async {
    final current = _profile;
    if (current == null) return;
    setState(() => _isSaving = true);
    try {
      await _authService.updateProfile(
        name: changes['name'] ?? current['name']?.toString() ?? '',
        phoneNumber:
            changes['phoneNumber'] ?? current['phoneNumber']?.toString() ?? '',
        address: changes['address'] ?? current['address']?.toString() ?? '',
        profilePicUrl:
            changes['profilePicUrl'] ??
            current['profilePictureData']?.toString() ??
            '',
      );
      final refreshed = await _authService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _profile = refreshed ?? current;
        _isSaving = false;
      });
      _showMessage('Profile updated.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  ImageProvider<Object>? _photoProvider() {
    final value = (_profile?['profilePictureData'] ?? _profile?['profilePic'])
        ?.toString();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('data:image')) {
      try {
        return MemoryImage(base64Decode(value.split(',').last));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(value);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _deepGreen,
        elevation: 0,
        title: const Text(
          'My profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading || _isSaving ? null : _loadProfile,
            tooltip: 'Refresh profile',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 42,
                      color: _muted,
                    ),
                    const SizedBox(height: 12),
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : profile == null
          ? const SizedBox.shrink()
          : Stack(
              children: [
                RefreshIndicator(
                  color: _green,
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileHeader(profile),
                              const SizedBox(height: 18),
                              _buildActivitySummary(),
                              const SizedBox(height: 22),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Personal information',
                                    style: TextStyle(
                                      color: _deepGreen,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _isSaving ? null : _editDetails,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 17,
                                    ),
                                    label: const Text('Edit'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildInformationSection(profile),
                              const SizedBox(height: 22),
                              OutlinedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Sign out'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9B3434),
                                  side: const BorderSide(
                                    color: Color(0xFFE8CACA),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSaving)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x33FFFFFF),
                      child: Center(
                        child: CircularProgressIndicator(color: _green),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile) {
    final name = (profile['name'] ?? 'Resident').toString();
    final email = (profile['email'] ?? '').toString();
    final photo = _photoProvider();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepGreen, _green],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xFFE6F3E9),
                  backgroundImage: photo,
                  onBackgroundImageError: photo == null ? null : (_, _) {},
                  child: photo == null
                      ? Text(
                          _initials(name),
                          style: const TextStyle(
                            color: _deepGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _isSaving ? null : _chooseProfilePhoto,
                    tooltip: 'Change profile photo',
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: _deepGreen,
                      size: 19,
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 38,
                      height: 38,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD6EAE2), fontSize: 13),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_outlined, color: Color(0xFFB9E9B8), size: 16),
                SizedBox(width: 6),
                Text(
                  'RESIDENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    return Row(
      children: [
        Expanded(
          child: _statPanel(
            'Reports submitted',
            _totalReports.toString(),
            Icons.description_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statPanel(
            'Resolved',
            _resolvedReports.toString(),
            Icons.task_alt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _statPanel(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE8DE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: _green, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _deepGreen,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(Map<String, dynamic> profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE8DE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _informationRow(
            Icons.person_outline,
            'Full name',
            _valueOrFallback(profile['name'], 'Add your name'),
          ),
          const Divider(height: 1, indent: 54, endIndent: 16),
          _informationRow(
            Icons.mail_outline,
            'Email address',
            _valueOrFallback(profile['email'], 'Not available'),
          ),
          const Divider(height: 1, indent: 54, endIndent: 16),
          _informationRow(
            Icons.phone_outlined,
            'Phone number',
            _valueOrFallback(profile['phoneNumber'], 'Add a phone number'),
          ),
          const Divider(height: 1, indent: 54, endIndent: 16),
          _informationRow(
            Icons.location_on_outlined,
            'Home address',
            _valueOrFallback(profile['address'], 'Add your address'),
          ),
        ],
      ),
    );
  }

  Widget _informationRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: _green, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF172B24),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrFallback(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'R';
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final Map<String, dynamic> profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile['name']?.toString() ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profile['phoneNumber']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: widget.profile['address']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final values = {
      'name': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    FocusScope.of(context).unfocus();
    if (keyboardVisible) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;
    Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 26),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E2DC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Personal details',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: _ResidentProfileScreenState._deepGreen,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your name.'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 32,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final phone = (value ?? '').trim();
                  if (phone.isNotEmpty &&
                      !RegExp(r'^[+0-9() .-]{7,32}$').hasMatch(phone)) {
                    return 'Enter a valid phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 240,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Home address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save details'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _ResidentProfileScreenState._green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
