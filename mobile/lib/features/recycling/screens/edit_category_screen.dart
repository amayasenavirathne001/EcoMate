import 'package:flutter/material.dart';
import '../../../models/waste_category.dart';
import '../theme/recycling_colors.dart';
import '../services/recycling_service.dart';

class EditCategoryScreen extends StatefulWidget {
  final WasteCategory category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _descController;
  late List<TextEditingController> _commonItemsControllers;
  late List<TextEditingController> _dosControllers;
  late List<TextEditingController> _dontsControllers;
  late List<TextEditingController> _prepStepsControllers;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.category.description);
    _commonItemsControllers = widget.category.commonItems.map((e) => TextEditingController(text: e)).toList();
    _dosControllers = widget.category.dos.map((e) => TextEditingController(text: e)).toList();
    _dontsControllers = widget.category.donts.map((e) => TextEditingController(text: e)).toList();
    _prepStepsControllers = widget.category.preparationSteps.map((e) => TextEditingController(text: e)).toList();
  }

  @override
  void dispose() {
    _descController.dispose();
    for (var c in _commonItemsControllers) { c.dispose(); }
    for (var c in _dosControllers) { c.dispose(); }
    for (var c in _dontsControllers) { c.dispose(); }
    for (var c in _prepStepsControllers) { c.dispose(); }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updatedCategory = WasteCategory(
        id: widget.category.id,
        name: widget.category.name,
        isRecyclable: widget.category.isRecyclable,
        description: _descController.text.trim(),
        binColor: widget.category.binColor,
        binColorName: widget.category.binColorName,
        icon: widget.category.icon,
        commonItems: _commonItemsControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
        preparationSteps: _prepStepsControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
        dos: _dosControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
        donts: _dontsControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
      );

      final recyclingService = RecyclingService();
      await recyclingService.updateWasteCategory(updatedCategory);

      if (!mounted) return;
      Navigator.pop(context, updatedCategory); // Return updated category to refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RecyclingColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Icon(icon, color: RecyclingColors.deepForestGreen, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: RecyclingColors.deepForestGreen,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: RecyclingColors.cardBorder, height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildDynamicListSection(String title, IconData sectionIcon, List<TextEditingController> controllers) {
    return _buildSectionCard(
      title: title,
      icon: sectionIcon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controllers.asMap().entries.map((entry) {
            int idx = entry.key;
            var controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Enter item...',
                        filled: true,
                        fillColor: RecyclingColors.offWhite,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          controller.dispose();
                          controllers.removeAt(idx);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() => controllers.add(TextEditingController()));
              },
              icon: const Icon(Icons.add_circle, color: RecyclingColors.forestGreen),
              label: const Text(
                'Add Item',
                style: TextStyle(color: RecyclingColors.forestGreen, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: RecyclingColors.softGreen.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecyclingColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Edit Category',
          style: TextStyle(color: RecyclingColors.deepForestGreen, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: RecyclingColors.deepForestGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: RecyclingColors.deepForestGreen)) 
        : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
                      title: 'Description',
                      icon: Icons.description_rounded,
                      child: TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter category description...',
                          filled: true,
                          fillColor: RecyclingColors.offWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    _buildDynamicListSection('Common Items', Icons.checklist_rounded, _commonItemsControllers),
                    _buildDynamicListSection('Preparation Steps', Icons.cleaning_services_rounded, _prepStepsControllers),
                    _buildDynamicListSection('Dos', Icons.check_circle_outline_rounded, _dosControllers),
                    _buildDynamicListSection('Donts', Icons.cancel_outlined, _dontsControllers),
                    
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RecyclingColors.deepForestGreen,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 4,
                        shadowColor: RecyclingColors.deepForestGreen.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

