import 'package:flutter/material.dart';
import '../models/material_item.dart';
import '../models/recycling_centre.dart';
import '../models/waste_delivery_record.dart';
import '../theme/recycling_colors.dart';
import '../../../services/auth_service.dart';
import '../services/recycling_service.dart';
import '../../../screens/login_screen.dart';

class RecyclingDashboard extends StatefulWidget {
  const RecyclingDashboard({super.key});

  @override
  State<RecyclingDashboard> createState() => _RecyclingDashboardState();
}

class _RecyclingDashboardState extends State<RecyclingDashboard> {
  final AuthService _authService = AuthService();
  final RecyclingService _recyclingService = RecyclingService();

  int _selectedTab = 0;
  String _officerName = 'Officer';
  String _officerEmail = 'trash@gmail.com';
  RecyclingCentre? _myCentre;
  List<MaterialItem> _centreMaterials = [];
  bool _isLoading = true;

  // Waste Deliveries
  List<WasteDeliveryRecord> _deliveryRecords = [];
  final TextEditingController _deliverySearchController = TextEditingController();

  // Activity Monitoring Filters (SCRUM-60)
  String _selectedPeriodFilter = 'All'; // 'All', 'Today', 'This Week', 'This Month'
  String _selectedMaterialFilter = 'All'; // 'All', 'Plastic', 'Paper', 'Glass', 'Metal', 'E-Waste', 'Organic'

  @override
  void initState() {
    super.initState();
    _loadOfficerData();
  }

  @override
  void dispose() {
    _deliverySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadOfficerData() async {
    setState(() => _isLoading = true);

    final storedEmail = await _authService.getEmail();
    final storedName = await _authService.getName();

    final activeEmail = (storedEmail != null && storedEmail.isNotEmpty)
        ? storedEmail
        : 'trash@gmail.com';

    final activeName = (storedName != null && storedName.isNotEmpty)
        ? storedName
        : 'Officer';

    final centre = await _recyclingService.getCentreForOfficer(activeEmail);
    final materials = await _recyclingService.getCentreMaterialsForOfficer(activeEmail);
    final deliveries = await _recyclingService.fetchDeliveries(centreId: centre?.id);

    if (mounted) {
      setState(() {
        _officerEmail = activeEmail;
        _officerName = activeName;
        _myCentre = centre;
        _centreMaterials = materials;
        _deliveryRecords = deliveries;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold, color: RecyclingColors.darkText),
        ),
        content: const Text(
          'Are you sure you want to log out from the Recycling Officer Hub?',
          style: TextStyle(color: RecyclingColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: RecyclingColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _toggleStatus(bool isOpen) async {
    if (_myCentre == null) return;
    await _recyclingService.toggleCentreStatus(_myCentre!.id, isOpen);
    setState(() {
      _myCentre = _myCentre!.copyWith(isOpen: isOpen);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOpen
              ? 'Centre status updated to OPEN'
              : 'Centre status updated to CLOSED',
        ),
        backgroundColor: isOpen ? RecyclingColors.primaryGreen : RecyclingColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: RecyclingColors.primaryGreen),
                  SizedBox(width: 10),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: RecyclingColors.darkText,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: RecyclingColors.primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: RecyclingColors.primaryGreen, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.vpn_key_outlined, color: RecyclingColors.primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: RecyclingColors.primaryGreen, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: const Icon(Icons.check_circle_outline, color: RecyclingColors.primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: RecyclingColors.primaryGreen, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final current = currentPasswordController.text;
                    final newPass = newPasswordController.text;
                    final confirm = confirmPasswordController.text;

                    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all password fields'),
                          backgroundColor: RecyclingColors.error,
                        ),
                      );
                      return;
                    }

                    if (newPass.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New password must be at least 6 characters'),
                          backgroundColor: RecyclingColors.error,
                        ),
                      );
                      return;
                    }

                    if (newPass != confirm) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                          backgroundColor: RecyclingColors.error,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Password updated successfully!'),
                          ],
                        ),
                        backgroundColor: RecyclingColors.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RecyclingColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Update Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openEditCentreModal() {
    if (_myCentre == null) return;

    final nameController = TextEditingController(text: _myCentre!.name);
    final addressController = TextEditingController(text: _myCentre!.address);
    final cityController = TextEditingController(text: _myCentre!.city);
    final phoneController = TextEditingController(text: _myCentre!.contactNumber);
    final emailController = TextEditingController(text: _myCentre!.email);
    final hoursController = TextEditingController(text: _myCentre!.operatingHours);
    final notesController = TextEditingController(text: _myCentre!.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Centre Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: RecyclingColors.darkText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(nameController, 'Centre Name', Icons.storefront),
                const SizedBox(height: 12),
                _buildTextField(addressController, 'Address', Icons.location_on_outlined),
                const SizedBox(height: 12),
                _buildTextField(cityController, 'City / District', Icons.location_city_outlined),
                const SizedBox(height: 12),
                _buildTextField(phoneController, 'Contact Phone', Icons.phone_outlined),
                const SizedBox(height: 12),
                _buildTextField(emailController, 'Official Email', Icons.email_outlined),
                const SizedBox(height: 12),
                _buildTextField(hoursController, 'Operating Hours', Icons.access_time_outlined),
                const SizedBox(height: 12),
                _buildTextField(notesController, 'Policies & Notes', Icons.notes_outlined, maxLines: 2),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final updated = _myCentre!.copyWith(
                      name: nameController.text.trim(),
                      address: addressController.text.trim(),
                      city: cityController.text.trim(),
                      contactNumber: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      operatingHours: hoursController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                    await _recyclingService.saveOrUpdateCentre(updated);
                    setState(() => _myCentre = updated);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Centre details updated successfully'),
                        backgroundColor: RecyclingColors.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RecyclingColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openManageMaterialsModal() {
    if (_myCentre == null) return;

    List<MaterialItem> tempMaterials = List.from(_centreMaterials);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: RecyclingColors.primaryGreen),
                  SizedBox(width: 10),
                  Text(
                    'Manage Accepted Materials',
                    style: TextStyle(
                      color: RecyclingColors.darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tempMaterials.length,
                  itemBuilder: (context, index) {
                    final mat = tempMaterials[index];
                    return CheckboxListTile(
                      activeColor: RecyclingColors.primaryGreen,
                      secondary: mat.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                mat.imageUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.recycling, color: RecyclingColors.primaryGreen),
                              ),
                            )
                          : const Icon(Icons.recycling, color: RecyclingColors.primaryGreen),
                      title: Text(
                        mat.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: mat.isActive ? FontWeight.w600 : FontWeight.normal,
                          color: RecyclingColors.darkText,
                        ),
                      ),
                      subtitle: Text(
                        mat.category,
                        style: const TextStyle(fontSize: 11, color: RecyclingColors.secondaryText),
                      ),
                      value: mat.isActive,
                      onChanged: (bool? value) {
                        setModalState(() {
                          tempMaterials[index] = mat.copyWith(isActive: value ?? false);
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    for (final mat in tempMaterials) {
                      await _recyclingService.toggleMaterialStatus(mat.id, mat.isActive);
                    }

                    final acceptedNames = tempMaterials
                        .where((m) => m.isActive)
                        .map((m) => m.name)
                        .toList();

                    final unsupportedNames = tempMaterials
                        .where((m) => !m.isActive)
                        .map((m) => m.name)
                        .toList();

                    final updatedCentre = _myCentre!.copyWith(
                      acceptedMaterials: acceptedNames,
                      unsupportedMaterials: unsupportedNames,
                    );

                    await _recyclingService.saveOrUpdateCentre(updatedCentre);

                    setState(() {
                      _centreMaterials = tempMaterials;
                      _myCentre = updatedCentre;
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Accepted materials updated successfully'),
                        backgroundColor: RecyclingColors.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RecyclingColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Save Materials'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openRecordDeliveryModal() {
    final materialOptions = [
      'Plastic Bottles (PET)',
      'Cardboard & Paper',
      'Glass Bottles',
      'Aluminum & Metal Cans',
      'Electronic Waste (E-Waste)',
      'Tetra Pak Cartons',
      'Organic Waste',
    ];

    String selectedMaterial = materialOptions.first;
    final weightController = TextEditingController();
    final residentController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();

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
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.add_shopping_cart_rounded, color: RecyclingColors.primaryGreen),
                            SizedBox(width: 10),
                            Text(
                              'Record Waste Delivery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: RecyclingColors.darkText,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Recyclable Material Type *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RecyclingColors.darkText),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: RecyclingColors.softGreen.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RecyclingColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMaterial,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: RecyclingColors.primaryGreen),
                          items: materialOptions.map((mat) {
                            return DropdownMenuItem(
                              value: mat,
                              child: Row(
                                children: [
                                  Icon(_getMaterialIcon(mat), color: RecyclingColors.primaryGreen, size: 20),
                                  const SizedBox(width: 10),
                                  Text(mat, style: const TextStyle(fontSize: 14, color: RecyclingColors.darkText)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedMaterial = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Quantity / Weight (kg) *',
                        hintText: 'e.g. 15.5',
                        suffixText: 'kg',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: RecyclingColors.primaryGreen),
                        prefixIcon: const Icon(Icons.scale_rounded, color: RecyclingColors.primaryGreen, size: 20),
                        labelStyle: const TextStyle(color: RecyclingColors.secondaryText, fontSize: 14),
                        filled: true,
                        fillColor: RecyclingColors.softGreen.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: RecyclingColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: RecyclingColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: RecyclingColors.primaryGreen, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Quantity Presets (SCRUM-57)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1, 5, 10, 25, 50].map((addAmount) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text('+$addAmount kg', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                              backgroundColor: RecyclingColors.softGreen.withValues(alpha: 0.6),
                              side: const BorderSide(color: RecyclingColors.cardBorder),
                              labelStyle: const TextStyle(color: RecyclingColors.primaryGreen),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              onPressed: () {
                                final current = double.tryParse(weightController.text.trim()) ?? 0.0;
                                final updated = current + addAmount;
                                weightController.text = updated % 1 == 0 ? updated.toInt().toString() : updated.toStringAsFixed(1);
                                setModalState(() {});
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Live Eco Credits & Impact Preview (SCRUM-57)
                    Builder(
                      builder: (context) {
                        final currentWeight = double.tryParse(weightController.text.trim()) ?? 0.0;
                        final previewRecord = WasteDeliveryRecord(
                          id: '',
                          materialType: selectedMaterial,
                          weightKg: currentWeight,
                          deliveredBy: '',
                          contactNumber: '',
                          dateTime: DateTime.now(),
                          notes: '',
                        );

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: RecyclingColors.softGreen.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: RecyclingColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: RecyclingColors.primaryGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      previewRecord.materialCode,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+${previewRecord.ecoPoints} Eco-Credits',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: RecyclingColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '~${previewRecord.co2SavedKg.toStringAsFixed(1)} kg CO₂ avoided',
                                style: const TextStyle(fontSize: 11, color: RecyclingColors.secondaryText),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildTextField(residentController, 'Delivered By (Resident / Business)', Icons.person_outline),
                    const SizedBox(height: 14),

                    _buildTextField(phoneController, 'Contact Number (Optional)', Icons.phone_outlined),
                    const SizedBox(height: 14),

                    _buildTextField(notesController, 'Notes / Batch Condition', Icons.notes_outlined, maxLines: 2),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        final weight = double.tryParse(weightController.text.trim());
                        if (weight == null || weight <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid weight in kg.'),
                              backgroundColor: RecyclingColors.error,
                            ),
                          );
                          return;
                        }

                        final deliverer = residentController.text.trim().isNotEmpty
                            ? residentController.text.trim()
                            : 'Resident Drop-off';

                        final newRecord = WasteDeliveryRecord(
                          id: '',
                          recyclingCentreId: _myCentre?.id,
                          recyclingCentreName: _myCentre?.name,
                          materialType: selectedMaterial,
                          weightKg: weight,
                          deliveredBy: deliverer,
                          contactNumber: phoneController.text.trim(),
                          dateTime: DateTime.now(),
                          notes: notesController.text.trim().isNotEmpty
                              ? notesController.text.trim()
                              : 'Standard delivery',
                        );

                        final saved = await _recyclingService.recordDelivery(newRecord);

                        setState(() {
                          _deliveryRecords.insert(0, saved ?? newRecord);
                        });

                        if (!context.mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Delivery recorded: ${weight.toStringAsFixed(1)} kg $selectedMaterial'),
                                ),
                              ],
                            ),
                            backgroundColor: RecyclingColors.primaryGreen,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RecyclingColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Delivery Record',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openDeliveryDetailsModal(WasteDeliveryRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: RecyclingColors.softGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_getMaterialIcon(record.materialType), color: RecyclingColors.primaryGreen),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        record.id,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: RecyclingColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: RecyclingColors.cardBorder),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.recycling_rounded, 'Material', '${record.materialType} (${record.materialCode})'),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.scale_rounded, 'Weight', '${record.weightKg.toStringAsFixed(1)} kg'),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.stars_rounded, 'Eco-Credits', '+${record.ecoPoints} points'),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.energy_savings_leaf_rounded, 'CO₂ Avoided', '~${record.co2SavedKg.toStringAsFixed(1)} kg CO₂'),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.person_outline, 'Delivered By', record.deliveredBy),
              if (record.contactNumber.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildDetailRow(Icons.phone_outlined, 'Contact', record.contactNumber),
              ],
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.access_time_outlined,
                'Recorded At',
                '${record.dateTime.day}/${record.dateTime.month}/${record.dateTime.year} - ${record.dateTime.hour.toString().padLeft(2, '0')}:${record.dateTime.minute.toString().padLeft(2, '0')}',
              ),
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildDetailRow(Icons.notes_outlined, 'Notes', record.notes),
              ],
            ],
          ),
        );
      },
    );
  }

  IconData _getMaterialIcon(String material) {
    final m = material.toLowerCase();
    if (m.contains('plastic')) return Icons.local_drink_outlined;
    if (m.contains('paper') || m.contains('cardboard')) return Icons.article_outlined;
    if (m.contains('glass')) return Icons.wine_bar_outlined;
    if (m.contains('metal') || m.contains('can') || m.contains('aluminum')) return Icons.inventory_2_outlined;
    if (m.contains('electronic') || m.contains('e-waste')) return Icons.devices_other_outlined;
    if (m.contains('tetra') || m.contains('carton')) return Icons.takeout_dining_outlined;
    if (m.contains('organic')) return Icons.eco_outlined;
    return Icons.recycling_rounded;
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: RecyclingColors.primaryGreen, size: 20),
        labelStyle: const TextStyle(color: RecyclingColors.secondaryText, fontSize: 14),
        filled: true,
        fillColor: RecyclingColors.softGreen.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RecyclingColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RecyclingColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RecyclingColors.primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: RecyclingColors.primaryGreen),
        const SizedBox(width: 10),
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(
              color: RecyclingColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: RecyclingColors.darkText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDeliveryDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:${dt.minute.toString().padLeft(2, '0')} $period';

    if (difference.inDays == 0 && now.day == dt.day) {
      return 'Today | $timeStr';
    } else if (difference.inDays <= 1 && now.day - dt.day == 1) {
      return 'Yesterday | $timeStr';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} | $timeStr';
    }
  }

  // =========================================================================
  // MAIN BUILD & TAB ROUTING
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecyclingColors.pageBg,
      appBar: _buildHeader(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: RecyclingColors.primaryGreen))
          : SafeArea(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildHomeTab(),
                  _buildDeliveriesTab(),
                  _buildFacilityTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // =========================================================================
  // APPBAR HEADER
  // =========================================================================

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(bottom: BorderSide(color: RecyclingColors.cardBorder, width: 1)),
      title: Row(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(
                  text: 'Eco',
                  style: TextStyle(color: RecyclingColors.darkText),
                ),
                TextSpan(
                  text: 'Mate',
                  style: TextStyle(color: RecyclingColors.primaryGreen),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: RecyclingColors.softGreen,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: RecyclingColors.cardBorder),
            ),
            child: const Text(
              'Recycle Hub',
              style: TextStyle(
                color: RecyclingColors.primaryGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loadOfficerData,
          icon: const Icon(Icons.refresh_rounded, color: RecyclingColors.primaryGreen),
          tooltip: 'Refresh Hub',
        ),
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, color: Colors.grey),
          tooltip: 'Logout',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // =========================================================================
  // TAB 0: HOME / OVERVIEW
  // =========================================================================

  Widget _buildHomeTab() {
    final totalWeight = _deliveryRecords.fold<double>(0.0, (sum, r) => sum + r.weightKg);
    final acceptedList = _centreMaterials.where((m) => m.isActive).toList();

    return RefreshIndicator(
      color: RecyclingColors.primaryGreen,
      onRefresh: _loadOfficerData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting Card with Officer Avatar Icon
                _buildGreetingCard(),

                const SizedBox(height: 14),

                // Illustration Banner Card
                _buildIllustrationBannerCard(),

                const SizedBox(height: 14),

                // Linked Facility Operations Card
                _buildOperationsHeroCard(),

                const SizedBox(height: 16),

                // 3 KPI Metric Stat Cards (Mobile Friendly)
                Row(
                  children: [
                    Expanded(
                      child: _buildHomeKpiCard(
                        'Total Inflow',
                        '${totalWeight.toStringAsFixed(1)} kg',
                        Icons.scale_rounded,
                        RecyclingColors.primaryGreen,
                        RecyclingColors.softGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildHomeKpiCard(
                        'Batches',
                        '${_deliveryRecords.length}',
                        Icons.receipt_long_rounded,
                        const Color(0xFF0284C7),
                        const Color(0xFFE0F2FE),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildHomeKpiCard(
                        'Accepted',
                        '${acceptedList.length}',
                        Icons.recycling_rounded,
                        const Color(0xFF8B5CF6),
                        const Color(0xFFF3E8FF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Quick Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: RecyclingColors.darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedTab = 1),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View Logs', style: TextStyle(color: RecyclingColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: RecyclingColors.primaryGreen),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Record Delivery',
                        subtitle: 'Log incoming batch',
                        color: RecyclingColors.primaryGreen,
                        onTap: _openRecordDeliveryModal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.tune_rounded,
                        title: 'Manage Items',
                        subtitle: 'Toggle accepted',
                        color: RecyclingColors.mediumGreen,
                        onTap: _openManageMaterialsModal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Recent Deliveries List Preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Waste Inflow',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: RecyclingColors.darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedTab = 1),
                      child: const Text('See All', style: TextStyle(color: RecyclingColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (_deliveryRecords.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: RecyclingColors.cardBorder),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No deliveries logged yet',
                          style: TextStyle(fontWeight: FontWeight.bold, color: RecyclingColors.darkText),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap "+ Record Delivery" to log the first batch.',
                          style: TextStyle(color: RecyclingColors.secondaryText, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _deliveryRecords.take(4).length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final record = _deliveryRecords[i];
                      return _buildDeliveryItemCard(record);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF9FFF7),
            Color(0xFFF1F9ED),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RecyclingColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Professional Officer Avatar Icon (Vector Dummy Avatar)
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0E8A38), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: RecyclingColors.primaryGreen.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_officerName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RecyclingColors.darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _officerEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RecyclingColors.secondaryText,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (_myCentre?.isOpen ?? false)
                            ? RecyclingColors.softGreen
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (_myCentre?.isOpen ?? false)
                              ? RecyclingColors.cardBorder
                              : const Color(0xFFFFCDD2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_myCentre?.isOpen ?? false)
                                  ? RecyclingColors.primaryGreen
                                  : RecyclingColors.error,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (_myCentre?.isOpen ?? false) ? 'OPEN FOR DROP-OFFS' : 'CLOSED',
                            style: TextStyle(
                              color: (_myCentre?.isOpen ?? false)
                                  ? RecyclingColors.primaryGreen
                                  : RecyclingColors.error,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationBannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RecyclingColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: RecyclingColors.softGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SMART OPERATIONS',
                    style: TextStyle(
                      color: RecyclingColors.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Recycling Inflow Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: RecyclingColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Record drop-offs, sort recyclable materials, and monitor collection weights in real time.',
                  style: TextStyle(fontSize: 12, color: RecyclingColors.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/onboarding_2.png',
              height: 75,
              width: 75,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: RecyclingColors.softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.recycling_rounded, color: RecyclingColors.primaryGreen, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RecyclingColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RecyclingColors.softGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.store_mall_directory_rounded,
                  color: RecyclingColors.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LINKED FACILITY',
                      style: TextStyle(
                        color: RecyclingColors.primaryGreen,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _myCentre?.name ?? 'No Facility Assigned',
                      style: const TextStyle(
                        color: RecyclingColors.darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _myCentre?.address ?? 'Contact Council Admin',
                      style: const TextStyle(color: RecyclingColors.secondaryText, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_myCentre != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: RecyclingColors.cardBorder),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 15, color: RecyclingColors.secondaryText),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _myCentre!.operatingHours,
                          style: const TextStyle(color: RecyclingColors.secondaryText, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _myCentre!.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: _myCentre!.isOpen ? RecyclingColors.primaryGreen : RecyclingColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: _myCentre!.isOpen,
                      activeThumbColor: RecyclingColors.primaryGreen,
                      activeTrackColor: RecyclingColors.softGreen,
                      onChanged: _toggleStatus,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHomeKpiCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RecyclingColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: RecyclingColors.secondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RecyclingColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: RecyclingColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10.5, color: RecyclingColors.secondaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryItemCard(WasteDeliveryRecord record) {
    return InkWell(
      onTap: () => _openDeliveryDetailsModal(record),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RecyclingColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: RecyclingColors.softGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMaterialIcon(record.materialType),
                color: RecyclingColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          record.materialType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: RecyclingColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: RecyclingColors.softGreen,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: RecyclingColors.cardBorder, width: 0.8),
                        ),
                        child: Text(
                          record.materialCode,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: RecyclingColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'By ${record.deliveredBy}',
                    style: const TextStyle(fontSize: 11.5, color: RecyclingColors.secondaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _formatDeliveryDate(record.dateTime),
                        style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${record.ecoPoints} pts',
                        style: const TextStyle(fontSize: 10.5, color: RecyclingColors.primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: RecyclingColors.softGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: RecyclingColors.cardBorder),
                  ),
                  child: Text(
                    '${record.weightKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: RecyclingColors.primaryGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  record.id,
                  style: const TextStyle(fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 1: DELIVERIES / INFLOW LOGS
  // =========================================================================

  Widget _buildDeliveriesTab() {
    final now = DateTime.now();
    final query = _deliverySearchController.text.trim().toLowerCase();

    final filtered = _deliveryRecords.where((r) {
      // 1. Text Query Filter
      final matchesQuery = query.isEmpty ||
          r.materialType.toLowerCase().contains(query) ||
          r.deliveredBy.toLowerCase().contains(query) ||
          r.id.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      // 2. Material Filter
      if (_selectedMaterialFilter != 'All') {
        if (!r.materialType.toLowerCase().contains(_selectedMaterialFilter.toLowerCase())) {
          return false;
        }
      }

      // 3. Period Filter (SCRUM-60)
      if (_selectedPeriodFilter == 'Today') {
        final isToday = r.dateTime.year == now.year &&
            r.dateTime.month == now.month &&
            r.dateTime.day == now.day;
        if (!isToday) return false;
      } else if (_selectedPeriodFilter == 'This Week') {
        final diffDays = now.difference(r.dateTime).inDays;
        if (diffDays > 7 || diffDays < 0) return false;
      } else if (_selectedPeriodFilter == 'This Month') {
        final isThisMonth = r.dateTime.year == now.year &&
            r.dateTime.month == now.month;
        if (!isThisMonth) return false;
      }

      return true;
    }).toList();

    final totalWeight = filtered.fold<double>(0.0, (sum, r) => sum + r.weightKg);
    final totalPoints = filtered.fold<int>(0, (sum, r) => sum + r.ecoPoints);
    final totalCo2 = filtered.fold<double>(0.0, (sum, r) => sum + r.co2SavedKg);
    final avgWeight = filtered.isNotEmpty ? totalWeight / filtered.length : 0.0;

    final periodOptions = ['All', 'Today', 'This Week', 'This Month'];
    final materialFilterOptions = ['All', 'Plastic', 'Paper', 'Glass', 'Metal', 'E-Waste', 'Organic'];

    return Scaffold(
      backgroundColor: RecyclingColors.pageBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRecordDeliveryModal,
        backgroundColor: RecyclingColors.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Record Delivery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOfficerData,
        color: RecyclingColors.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar & Analytics Trigger
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _deliverySearchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search material, resident, ID...',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            prefixIcon: const Icon(Icons.search_rounded, color: RecyclingColors.primaryGreen),
                            suffixIcon: _deliverySearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _deliverySearchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: RecyclingColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: RecyclingColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: RecyclingColors.primaryGreen, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => _openActivityAnalyticsModal(filtered),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: RecyclingColors.cardBorder),
                            ),
                            child: const Icon(Icons.bar_chart_rounded, color: RecyclingColors.primaryGreen, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Period Filter Tabs (SCRUM-60: Monitoring Timeframes)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: periodOptions.map((period) {
                        final isSelected = _selectedPeriodFilter == period;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(period),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedPeriodFilter = period);
                            },
                            selectedColor: RecyclingColors.primaryGreen,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : RecyclingColors.darkText,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: BorderSide(
                              color: isSelected ? RecyclingColors.primaryGreen : RecyclingColors.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Material Category Filter Chips (SCRUM-60)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: materialFilterOptions.map((mat) {
                        final isSelected = _selectedMaterialFilter == mat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(mat),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() => _selectedMaterialFilter = mat);
                            },
                            selectedColor: RecyclingColors.softGreen,
                            backgroundColor: Colors.white,
                            checkmarkColor: RecyclingColors.primaryGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? RecyclingColors.primaryGreen : RecyclingColors.secondaryText,
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: BorderSide(
                              color: isSelected ? RecyclingColors.primaryGreen : RecyclingColors.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Activity Monitoring Analytics Card (SCRUM-60 KPI Bar)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: RecyclingColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insights_rounded, color: RecyclingColors.primaryGreen, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Activity Insights (${_selectedPeriodFilter == 'All' ? 'All Time' : _selectedPeriodFilter})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: RecyclingColors.darkText,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${filtered.length} drop-offs',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: RecyclingColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: RecyclingColors.cardBorder),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMonitoringKpi(
                              '${totalWeight.toStringAsFixed(1)} kg',
                              'Total Weight',
                              Icons.scale_rounded,
                            ),
                            _buildMonitoringKpi(
                              '+$totalPoints',
                              'Eco-Credits',
                              Icons.stars_rounded,
                            ),
                            _buildMonitoringKpi(
                              '${totalCo2.toStringAsFixed(1)} kg',
                              'CO₂ Avoided',
                              Icons.energy_savings_leaf_rounded,
                            ),
                            _buildMonitoringKpi(
                              '${avgWeight.toStringAsFixed(1)} kg',
                              'Avg Drop-off',
                              Icons.pie_chart_outline_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(36),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 46, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text(
                            'No activities match your filters',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: RecyclingColors.darkText),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try clearing the search or category filters.',
                            style: TextStyle(color: RecyclingColors.secondaryText, fontSize: 12.5),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _deliverySearchController.clear();
                                _selectedPeriodFilter = 'All';
                                _selectedMaterialFilter = 'All';
                              });
                            },
                            icon: const Icon(Icons.restart_alt_rounded, size: 16),
                            label: const Text('Reset Filters'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: RecyclingColors.primaryGreen,
                              side: const BorderSide(color: RecyclingColors.primaryGreen),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        return _buildDeliveryItemCard(filtered[i]);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonitoringKpi(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: RecyclingColors.primaryGreen, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: RecyclingColors.darkText,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: RecyclingColors.secondaryText,
          ),
        ),
      ],
    );
  }

  void _openActivityAnalyticsModal(List<WasteDeliveryRecord> records) {
    final Map<String, double> materialWeights = {};
    for (final r in records) {
      materialWeights[r.materialType] = (materialWeights[r.materialType] ?? 0.0) + r.weightKg;
    }

    final totalKg = materialWeights.values.fold<double>(0.0, (s, w) => s + w);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart_rounded, color: RecyclingColors.primaryGreen),
                      SizedBox(width: 8),
                      Text(
                        'Material Breakdown Analytics',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: RecyclingColors.darkText),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Total Volume: ${totalKg.toStringAsFixed(1)} kg across ${records.length} records',
                style: const TextStyle(fontSize: 12.5, color: RecyclingColors.secondaryText),
              ),
              const Divider(height: 20, color: RecyclingColors.cardBorder),
              if (materialWeights.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No data recorded for this timeframe.', textAlign: TextAlign.center),
                )
              else
                ...materialWeights.entries.map((entry) {
                  final pct = totalKg > 0 ? (entry.value / totalKg) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: RecyclingColors.darkText),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(1)} kg (${pct.toStringAsFixed(0)}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: RecyclingColors.primaryGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalKg > 0 ? entry.value / totalKg : 0.0,
                            minHeight: 8,
                            backgroundColor: RecyclingColors.softGreen,
                            valueColor: const AlwaysStoppedAnimation<Color>(RecyclingColors.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 2: FACILITY & MATERIALS
  // =========================================================================

  Widget _buildFacilityTab() {
    final acceptedList = _centreMaterials.where((m) => m.isActive).toList();
    final unsupportedList = _centreMaterials.where((m) => !m.isActive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_myCentre == null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RecyclingColors.cardBorder),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.storefront_outlined, size: 48, color: RecyclingColors.primaryGreen),
                      SizedBox(height: 10),
                      Text(
                        'No Centre Assigned',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: RecyclingColors.darkText),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Please ask your municipal administrator to register your centre email.',
                        style: TextStyle(color: RecyclingColors.secondaryText, fontSize: 12.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Centre Profile Details Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RecyclingColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _myCentre!.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: RecyclingColors.darkText,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _openEditCentreModal,
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Edit Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RecyclingColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                              textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: RecyclingColors.cardBorder),
                      const SizedBox(height: 6),
                      _buildDetailRow(Icons.location_on_outlined, 'Address', _myCentre!.address),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.location_city_outlined, 'City', _myCentre!.city),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.phone_outlined, 'Phone', _myCentre!.contactNumber),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.email_outlined, 'Email', _myCentre!.email),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.access_time_outlined, 'Hours', _myCentre!.operatingHours),
                      if (_myCentre!.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.notes_outlined, 'Notes', _myCentre!.notes),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Operational Status Switch Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RecyclingColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _myCentre!.isOpen ? RecyclingColors.primaryGreen : RecyclingColors.error,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Operational Status',
                                style: TextStyle(fontSize: 11.5, color: RecyclingColors.secondaryText),
                              ),
                              Text(
                                _myCentre!.isOpen ? 'OPEN FOR DROP-OFFS' : 'TEMPORARILY CLOSED',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: _myCentre!.isOpen ? RecyclingColors.primaryGreen : RecyclingColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _myCentre!.isOpen,
                        activeThumbColor: RecyclingColors.primaryGreen,
                        activeTrackColor: RecyclingColors.softGreen,
                        onChanged: _toggleStatus,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Accepted Materials Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RecyclingColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: RecyclingColors.primaryGreen, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Accepted Materials (${acceptedList.length})',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: RecyclingColors.darkText,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _openManageMaterialsModal,
                            icon: const Icon(Icons.tune_rounded, size: 15),
                            label: const Text('Manage'),
                            style: TextButton.styleFrom(foregroundColor: RecyclingColors.primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (acceptedList.isEmpty)
                        const Text(
                          'No materials marked as accepted. Tap "Manage" to select.',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      else
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: acceptedList.map((mat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: RecyclingColors.softGreen,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: RecyclingColors.cardBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check, size: 13, color: RecyclingColors.primaryGreen),
                                  const SizedBox(width: 5),
                                  Text(
                                    mat.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: RecyclingColors.darkText,
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

                const SizedBox(height: 14),

                // Unsupported Items Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RecyclingColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 17),
                          const SizedBox(width: 8),
                          Text(
                            'Unsupported Items (${unsupportedList.length})',
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: RecyclingColors.darkText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (unsupportedList.isEmpty)
                        const Text(
                          'None - all categories currently accepted.',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      else
                        ...unsupportedList.map((mat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.remove_circle_outline, size: 13, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    mat.name,
                                    style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 3: ACCOUNT & SETTINGS
  // =========================================================================

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Card with Officer Vector Avatar
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: RecyclingColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.025),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0E8A38), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: RecyclingColors.primaryGreen.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _officerName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: RecyclingColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _officerEmail,
                      style: const TextStyle(fontSize: 12.5, color: RecyclingColors.secondaryText),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: RecyclingColors.softGreen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: RecyclingColors.cardBorder),
                      ),
                      child: const Text(
                        'RECYCLING OFFICER',
                        style: TextStyle(
                          color: RecyclingColors.primaryGreen,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Facility Affiliation Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: RecyclingColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: RecyclingColors.softGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: RecyclingColors.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Linked Facility', style: TextStyle(fontSize: 11, color: RecyclingColors.secondaryText)),
                          Text(
                            _myCentre?.name ?? 'Unassigned',
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: RecyclingColors.darkText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Security & Account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: RecyclingColors.darkText,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: RecyclingColors.cardBorder),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: RecyclingColors.softGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_outline_rounded, color: RecyclingColors.primaryGreen, size: 20),
                      ),
                      title: const Text(
                        'Change Password',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: RecyclingColors.darkText),
                      ),
                      subtitle: const Text(
                        'Update your account password',
                        style: TextStyle(fontSize: 11.5, color: RecyclingColors.secondaryText),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: _openChangePasswordDialog,
                    ),
                    const Divider(height: 1, indent: 55, color: RecyclingColors.cardBorder),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: RecyclingColors.softGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: RecyclingColors.primaryGreen, size: 20),
                      ),
                      title: const Text(
                        'Drop-off Notifications',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: RecyclingColors.darkText),
                      ),
                      subtitle: const Text(
                        'Receive alerts when deliveries arrive',
                        style: TextStyle(fontSize: 11.5, color: RecyclingColors.secondaryText),
                      ),
                      trailing: Switch(
                        value: true,
                        activeThumbColor: RecyclingColors.primaryGreen,
                        activeTrackColor: RecyclingColors.softGreen,
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Danger Zone: Log Out
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: RecyclingColors.error, size: 20),
                  ),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: RecyclingColors.error),
                  ),
                  subtitle: const Text(
                    'Sign out from this device',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: RecyclingColors.error),
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // RESPONSIVE BOTTOM NAVIGATION BAR
  // =========================================================================

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: RecyclingColors.cardBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(child: _bottomNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: _bottomNavItem(1, Icons.inventory_2_rounded, 'Deliveries')),
              Expanded(child: _bottomNavItem(2, Icons.storefront_rounded, 'Facility')),
              Expanded(child: _bottomNavItem(3, Icons.person_rounded, 'Account')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? RecyclingColors.primaryGreen : Colors.black45,
            size: 23,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? RecyclingColors.primaryGreen : Colors.black45,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}