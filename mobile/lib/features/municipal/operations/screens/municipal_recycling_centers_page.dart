import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../../../recycling/models/recycling_centre.dart';
import '../../../recycling/services/recycling_service.dart';

class MunicipalRecyclingCentersPage extends StatefulWidget {
  const MunicipalRecyclingCentersPage({super.key});

  @override
  State<MunicipalRecyclingCentersPage> createState() => _MunicipalRecyclingCentersPageState();
}

class _MunicipalRecyclingCentersPageState extends State<MunicipalRecyclingCentersPage> {
  final RecyclingService _recyclingService = RecyclingService();
  final TextEditingController _searchController = TextEditingController();

  List<RecyclingCentre> _allCentres = [];
  List<RecyclingCentre> _filteredCentres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCentres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCentres() async {
    setState(() => _isLoading = true);
    final list = await _recyclingService.fetchRecyclingCentres();
    if (mounted) {
      setState(() {
        _allCentres = list;
        _filterCentres();
        _isLoading = false;
      });
    }
  }

  void _filterCentres() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredCentres = List.from(_allCentres);
    } else {
      _filteredCentres = _allCentres.where((c) {
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

    final availableMaterials = [
      'Plastic Bottles (PET #1)',
      'Rigid Plastics (HDPE #2, PP #5)',
      'Cardboard & Office Paper',
      'Newspapers & Magazines',
      'Aluminum Beverage Cans',
      'Steel & Tin Food Cans',
      'Glass Bottles & Jars',
      'Mobile Phones & Tablets',
      'Computers & Laptops',
    ];

    final Set<String> selectedMaterials = {
      'Plastic Bottles (PET #1)',
      'Cardboard & Office Paper',
      'Aluminum Beverage Cans',
      'Glass Bottles & Jars',
    };

    bool isSubmitting = false;

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
                            Icon(Icons.add_business_rounded, color: MunicipalColors.darkGreen),
                            SizedBox(width: 10),
                            Text(
                              'Add Recycling Centre',
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

                    _buildFormField(nameController, 'Centre Name *', Icons.storefront),
                    const SizedBox(height: 12),
                    _buildFormField(cityController, 'City / Municipal Ward *', Icons.location_city_rounded),
                    const SizedBox(height: 12),
                    _buildFormField(addressController, 'Full Street Address *', Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    _buildFormField(phoneController, 'Contact Phone *', Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildFormField(emailController, 'Officer Login Email (e.g. officer@gmail.com) *', Icons.badge_outlined, keyboardType: TextInputType.emailAddress),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableMaterials.map((mat) {
                        final isSelected = selectedMaterials.contains(mat);
                        return FilterChip(
                          label: Text(mat),
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
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? MunicipalColors.secondaryGreen : MunicipalColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final city = cityController.text.trim();
                              final address = addressController.text.trim();
                              final phone = phoneController.text.trim();
                              final officerEmail = emailController.text.trim();

                              if (name.isEmpty || city.isEmpty || address.isEmpty || phone.isEmpty || officerEmail.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill all required fields (*) including Officer Email'),
                                    backgroundColor: MunicipalColors.error,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final newCentre = RecyclingCentre(
                                id: '',
                                officerEmail: officerEmail,
                                name: name,
                                address: address,
                                city: city,
                                distanceKm: 1.5,
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

                              final created = await _recyclingService.createCentre(newCentre);

                              if (!context.mounted) return;
                              Navigator.pop(context);

                              if (created != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Recycling centre "${created.name}" registered successfully!'),
                                    backgroundColor: MunicipalColors.secondaryGreen,
                                  ),
                                );
                                _loadCentres();
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
                              'Save Recycling Centre',
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

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
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
      backgroundColor: MunicipalColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: MunicipalColors.darkGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recycling Centres',
          style: TextStyle(
            color: MunicipalColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: MunicipalColors.darkGreen),
            onPressed: _loadCentres,
            tooltip: 'Refresh',
          ),
        ],
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
                        _filterCentres();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by centre name, city, address...',
                      hintStyle: const TextStyle(color: MunicipalColors.mutedText, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: MunicipalColors.secondaryGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: MunicipalColors.secondaryText),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filterCentres();
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
                        'Total Centres: ${_filteredCentres.length}',
                        style: const TextStyle(
                          color: MunicipalColors.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openAddCenterDialog,
                        icon: const Icon(Icons.add_circle_outline, size: 16, color: MunicipalColors.secondaryGreen),
                        label: const Text(
                          'Add Centre',
                          style: TextStyle(
                            color: MunicipalColors.secondaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: MunicipalColors.border),

            // Centres List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen),
                    )
                  : _filteredCentres.isEmpty
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
                                'No recycling centres found',
                                style: TextStyle(
                                  color: MunicipalColors.secondaryText,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _openAddCenterDialog,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Add Your First Centre'),
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
                          itemCount: _filteredCentres.length,
                          itemBuilder: (context, index) {
                            final centre = _filteredCentres[index];
                            return _buildCentreCard(centre);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentreCard(RecyclingCentre centre) {
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
                        centre.name,
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
                            centre.city,
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
                    color: centre.isOpen
                        ? MunicipalColors.success.withValues(alpha: 0.12)
                        : MunicipalColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    centre.isOpen ? 'OPEN' : 'CLOSED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: centre.isOpen ? MunicipalColors.darkGreen : MunicipalColors.error,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: MunicipalColors.error, size: 20),
                  tooltip: 'Delete Centre',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Centre'),
                        content: Text('Are you sure you want to delete "${centre.name}"?'),
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
                      await _recyclingService.deleteCentre(centre.id);
                      _loadCentres();
                    }
                  },
                ),
              ],
            ),

            if (centre.officerEmail != null && centre.officerEmail!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 14, color: MunicipalColors.secondaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    'Officer: ${centre.officerEmail}',
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
                    centre.address,
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
                  centre.contactNumber,
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
                  centre.operatingHours,
                  style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
                ),
              ],
            ),

            if (centre.acceptedMaterials.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: centre.acceptedMaterials.take(4).map((mat) {
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
