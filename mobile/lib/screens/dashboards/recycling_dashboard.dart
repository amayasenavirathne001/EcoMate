import 'package:flutter/material.dart';
import '../../models/material_item.dart';
import '../../models/recycling_centre.dart';
import '../../services/auth_service.dart';
import '../../services/recycling_service.dart';
import '../login_screen.dart';

class WasteDeliveryRecord {
  final String id;
  final String materialType;
  final double weightKg;
  final String deliveredBy;
  final String contactNumber;
  final DateTime dateTime;
  final String notes;

  WasteDeliveryRecord({
    required this.id,
    required this.materialType,
    required this.weightKg,
    required this.deliveredBy,
    required this.contactNumber,
    required this.dateTime,
    required this.notes,
  });
}

class RecyclingDashboard extends StatefulWidget {
  const RecyclingDashboard({super.key});

  @override
  State<RecyclingDashboard> createState() => _RecyclingDashboardState();
}

class _RecyclingDashboardState extends State<RecyclingDashboard> {
  final AuthService _authService = AuthService();
  final RecyclingService _recyclingService = RecyclingService();

  String _officerName = 'Officer';
  String _officerEmail = 'stharanga.rog@gmail.com';
  RecyclingCentre? _myCentre;
  List<MaterialItem> _centreMaterials = [];
  bool _isLoading = true;

  // Recyclable Waste Delivery Records
  final List<WasteDeliveryRecord> _deliveryRecords = [
    WasteDeliveryRecord(
      id: 'DEL-1048',
      materialType: 'Plastic Bottles (PET)',
      weightKg: 24.5,
      deliveredBy: 'Kamal Perera',
      contactNumber: '077-1234567',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Clean and sorted PET bottles',
    ),
    WasteDeliveryRecord(
      id: 'DEL-1047',
      materialType: 'Cardboard & Paper',
      weightKg: 58.0,
      deliveredBy: 'Colombo Green Eco',
      contactNumber: '011-2345678',
      dateTime: DateTime.now().subtract(const Duration(hours: 4, minutes: 15)),
      notes: 'Bundled and dry packaging boxes',
    ),
    WasteDeliveryRecord(
      id: 'DEL-1046',
      materialType: 'Glass Bottles',
      weightKg: 18.2,
      deliveredBy: 'Sunil Fernando',
      contactNumber: '071-9876543',
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      notes: 'Separated by clear and amber glass',
    ),
    WasteDeliveryRecord(
      id: 'DEL-1045',
      materialType: 'Aluminum & Metal Cans',
      weightKg: 12.0,
      deliveredBy: 'Nimali Silva',
      contactNumber: '076-5544332',
      dateTime: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      notes: 'Rinsed beverage cans',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadOfficerData();
  }

  Future<void> _loadOfficerData() async {
    setState(() => _isLoading = true);

    final storedEmail = await _authService.getEmail();
    final storedName = await _authService.getName();

    final activeEmail = (storedEmail != null && storedEmail.isNotEmpty)
        ? storedEmail
        : 'stharanga.rog@gmail.com';

    final activeName = (storedName != null && storedName.isNotEmpty)
        ? storedName
        : 'Officer';

    final centre = await _recyclingService.getCentreForOfficer(activeEmail);
    final materials = await _recyclingService.getCentreMaterialsForOfficer(activeEmail);

    if (mounted) {
      setState(() {
        _officerEmail = activeEmail;
        _officerName = activeName;
        _myCentre = centre;
        _centreMaterials = materials;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    if (!context.mounted) return;
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
        backgroundColor: isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
        duration: const Duration(seconds: 2),
      ),
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
            left: 24,
            right: 24,
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
                        color: Color(0xFF1F5520),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(nameController, 'Centre Name', Icons.storefront),
                const SizedBox(height: 12),
                _buildTextField(addressController, 'Address', Icons.location_on),
                const SizedBox(height: 12),
                _buildTextField(cityController, 'City / District', Icons.location_city),
                const SizedBox(height: 12),
                _buildTextField(phoneController, 'Contact Phone', Icons.phone),
                const SizedBox(height: 12),
                _buildTextField(emailController, 'Official Email', Icons.email),
                const SizedBox(height: 12),
                _buildTextField(hoursController, 'Operating Hours', Icons.access_time),
                const SizedBox(height: 12),
                _buildTextField(notesController, 'Policies & Notes', Icons.notes, maxLines: 2),
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
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5520),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  Icon(Icons.inventory_2_outlined, color: Color(0xFF1F5520)),
                  SizedBox(width: 10),
                  Text(
                    'Manage Accepted Materials',
                    style: TextStyle(
                      color: Color(0xFF1F5520),
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
                      activeColor: const Color(0xFF2E7D32),
                      secondary: mat.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                mat.imageUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.recycling, color: Color(0xFF2E7D32)),
                              ),
                            )
                          : const Icon(Icons.recycling, color: Color(0xFF2E7D32)),
                      title: Text(
                        mat.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: mat.isActive ? FontWeight.w600 : FontWeight.normal,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      subtitle: Text(
                        mat.category,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
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
                    // Save all toggled states to backend mapping table
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
                        content: Text('Accepted materials (is_active: 1/0) updated successfully'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5520),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                left: 24,
                right: 24,
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
                            Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF1F5520)),
                            SizedBox(width: 10),
                            Text(
                              'Record Recyclable Delivery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F5520),
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

                    // Material Category
                    const Text(
                      'Recyclable Material Type *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD9E3DA)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMaterial,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1F5520)),
                          items: materialOptions.map((mat) {
                            return DropdownMenuItem(
                              value: mat,
                              child: Row(
                                children: [
                                  Icon(_getMaterialIcon(mat), color: const Color(0xFF2E7D32), size: 20),
                                  const SizedBox(width: 10),
                                  Text(mat, style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748))),
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

                    // Weight Input
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity / Weight (kg) *',
                        hintText: 'e.g. 15.5',
                        suffixText: 'kg',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F5520)),
                        prefixIcon: const Icon(Icons.scale_rounded, color: Color(0xFF2E7D32), size: 20),
                        labelStyle: const TextStyle(color: Color(0xFF69756D), fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF8FAF7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD9E3DA)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD9E3DA)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Delivered By
                    _buildTextField(residentController, 'Delivered By (Resident / Business)', Icons.person_outline),
                    const SizedBox(height: 14),

                    // Contact Phone
                    _buildTextField(phoneController, 'Contact Number (Optional)', Icons.phone_outlined),
                    const SizedBox(height: 14),

                    // Notes
                    _buildTextField(notesController, 'Notes / Batch Condition', Icons.notes_outlined, maxLines: 2),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        final weight = double.tryParse(weightController.text.trim());
                        if (weight == null || weight <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid weight in kg.'),
                              backgroundColor: Color(0xFFC62828),
                            ),
                          );
                          return;
                        }

                        final deliverer = residentController.text.trim().isNotEmpty
                            ? residentController.text.trim()
                            : 'Resident Drop-off';

                        final newRecord = WasteDeliveryRecord(
                          id: 'DEL-${1000 + _deliveryRecords.length + 1}',
                          materialType: selectedMaterial,
                          weightKg: weight,
                          deliveredBy: deliverer,
                          contactNumber: phoneController.text.trim(),
                          dateTime: DateTime.now(),
                          notes: notesController.text.trim().isNotEmpty
                              ? notesController.text.trim()
                              : 'Standard delivery',
                        );

                        setState(() {
                          _deliveryRecords.insert(0, newRecord);
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Delivery ${newRecord.id} recorded: ${weight.toStringAsFixed(1)} kg $selectedMaterial'),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1F5520),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F5520),
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
          padding: const EdgeInsets.all(24),
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
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_getMaterialIcon(record.materialType), color: const Color(0xFF1F5520)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        record.id,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F5520),
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
              const Divider(color: Color(0xFFECEFF1)),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.recycling_rounded, 'Material', record.materialType),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.scale_rounded, 'Weight', '${record.weightKg.toStringAsFixed(1)} kg'),
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
                '${record.dateTime.day}/${record.dateTime.month}/${record.dateTime.year} • ${record.dateTime.hour.toString().padLeft(2, '0')}:${record.dateTime.minute.toString().padLeft(2, '0')}',
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

  Widget _buildDeliveriesSection() {
    final totalWeight = _deliveryRecords.fold<double>(0.0, (sum, r) => sum + r.weightKg);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E3DA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_rounded,
                      color: Color(0xFF1F5520),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Deliveries (${_deliveryRecords.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F5520),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _openRecordDeliveryModal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Delivery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F5520),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // KPIs Row
          Row(
            children: [
              Expanded(
                child: _buildDeliveryKpiCard(
                  'Deliveries',
                  '${_deliveryRecords.length}',
                  Icons.receipt_long_rounded,
                  const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDeliveryKpiCard(
                  'Total Weight',
                  '${totalWeight.toStringAsFixed(1)} kg',
                  Icons.scale_rounded,
                  const Color(0xFF1F5520),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDeliveryKpiCard(
                  'Avg / Entry',
                  _deliveryRecords.isNotEmpty
                      ? '${(totalWeight / _deliveryRecords.length).toStringAsFixed(1)} kg'
                      : '0 kg',
                  Icons.analytics_outlined,
                  const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Deliveries List
          const Text(
            'Recent Delivery Logs',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          if (_deliveryRecords.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No deliveries recorded yet. Tap "+ Record Delivery" to log the first batch.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _deliveryRecords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = _deliveryRecords[index];
                return InkWell(
                  onTap: () => _openDeliveryDetailsModal(record),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getMaterialIcon(record.materialType),
                            color: const Color(0xFF15803D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.materialType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'By ${record.deliveredBy}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _formatDeliveryDate(record.dateTime),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Text(
                                '${record.weightKg.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  color: Color(0xFF14532D),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                record.id,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDeliveryDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:${dt.minute.toString().padLeft(2, '0')} $period';

    if (difference.inDays == 0 && now.day == dt.day) {
      return 'Today • $timeStr';
    } else if (difference.inDays <= 1 && now.day - dt.day == 1) {
      return 'Yesterday • $timeStr';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} • $timeStr';
    }
  }

  Widget _buildDeliveryKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
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
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        labelStyle: const TextStyle(color: Color(0xFF69756D), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAF7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E3DA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E3DA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acceptedList = _centreMaterials.where((m) => m.isActive).toList();
    final unsupportedList = _centreMaterials.where((m) => !m.isActive).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.recycling_rounded,
                color: Color(0xFF1F5520),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recycling Officer Hub',
              style: TextStyle(
                color: Color(0xFF1F5520),
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFE57373)),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F5520)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Officer Profile Banner
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1F5520), Color(0xFF2E7D32)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1F5520).withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.badge_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, $_officerName',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _officerEmail,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // If no centre registered yet
                        if (_myCentre == null) ...[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFD9E3DA)),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.store_mall_directory_outlined,
                                  size: 54,
                                  color: Color(0xFF2E7D32),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No Facility Assigned',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F5520),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Please contact your Municipal Council Administrator to link your facility.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF69756D), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Live Status Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFD9E3DA)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _myCentre!.isOpen
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFC62828),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Operational Status',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF69756D),
                                          ),
                                        ),
                                        Text(
                                          _myCentre!.isOpen ? 'OPEN FOR DROP-OFFS' : 'TEMPORARILY CLOSED',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: _myCentre!.isOpen
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFFC62828),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _myCentre!.isOpen,
                                  activeThumbColor: const Color(0xFF1F5520),
                                  activeTrackColor: const Color(0xFFA5D6A7),
                                  onChanged: _toggleStatus,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Record Recyclable Waste Delivery & Log Section
                          _buildDeliveriesSection(),

                          const SizedBox(height: 20),

                          // Centre Profile Details Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFD9E3DA)),
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
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F5520),
                                        ),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _openEditCentreModal,
                                      icon: const Icon(Icons.edit_outlined, size: 16),
                                      label: const Text('Edit'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF1F5520),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Color(0xFFECEFF1)),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.location_on_outlined, 'Address', _myCentre!.address),
                                const SizedBox(height: 10),
                                _buildDetailRow(Icons.location_city_outlined, 'City', _myCentre!.city),
                                const SizedBox(height: 10),
                                _buildDetailRow(Icons.phone_outlined, 'Phone', _myCentre!.contactNumber),
                                const SizedBox(height: 10),
                                _buildDetailRow(Icons.email_outlined, 'Email', _myCentre!.email),
                                const SizedBox(height: 10),
                                _buildDetailRow(Icons.access_time_outlined, 'Hours', _myCentre!.operatingHours),
                                if (_myCentre!.notes.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _buildDetailRow(Icons.info_outline, 'Notes', _myCentre!.notes),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Accepted Materials Card (is_active == true / 1)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFD9E3DA)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Accepted Materials (${acceptedList.length})',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F5520),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: _openManageMaterialsModal,
                                      icon: const Icon(Icons.tune_rounded, size: 16),
                                      label: const Text('Manage'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF1F5520),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (acceptedList.isEmpty)
                                  const Text(
                                    'No materials currently marked as accepted. Tap "Manage" to select accepted materials.',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF757575), fontStyle: FontStyle.italic),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: acceptedList.map((mat) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFC8E6C9),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (mat.imageUrl.isNotEmpty) ...[
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.network(
                                                  mat.imageUrl,
                                                  width: 18,
                                                  height: 18,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Color(0xFF2E7D32),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                            ] else ...[
                                              const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Color(0xFF2E7D32),
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Text(
                                              mat.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1B5E20),
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

                          const SizedBox(height: 20),

                          // Unsupported Materials Card (is_active == false / 0)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFFFCDD2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.cancel_outlined,
                                      color: Color(0xFFC62828),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Unsupported Items (${unsupportedList.length})',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC62828),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (unsupportedList.isEmpty)
                                  const Text(
                                    'None â€” all categories are currently accepted.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF757575),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else
                                  ...unsupportedList.map((mat) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.remove_circle_outline,
                                            size: 14,
                                            color: Color(0xFFD32F2F),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              mat.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFB71C1C),
                                              ),
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
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF69756D),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}