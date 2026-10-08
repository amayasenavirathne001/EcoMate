import '../theme/recycling_colors.dart';
import 'package:flutter/material.dart';
import '../../../models/waste_category.dart';
import 'edit_category_screen.dart';
import '../../../services/auth_service.dart';
import '../services/recycling_service.dart';

class CategoryDetailScreen extends StatefulWidget {
  final WasteCategory category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late WasteCategory _category;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await AuthService().getRole();
    if (mounted) {
      setState(() {
        _isAdmin = role == 'COUNCIL_ADMIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;

    return Scaffold(
      backgroundColor: RecyclingColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: RecyclingColors.deepForestGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            color: RecyclingColors.deepForestGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
                    if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Category'),
                    content: Text('Are you sure you want to delete ${category.name}?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true), 
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await RecyclingService().deleteWasteCategory(category.id);
                    if (!mounted) return;
                    Navigator.pop(context); // Go back to the guide screen
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted successfully')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                  }
                }
              },
            ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit, color: RecyclingColors.deepForestGreen),
              onPressed: () async {
                final updatedCategory = await Navigator.push<WasteCategory>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCategoryScreen(category: _category),
                  ),
                );
                if (updatedCategory != null) {
                  setState(() {
                    _category = updatedCategory;
                  });
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card with Category Icon & Bin Color
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RecyclingColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: category.binColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.binColor,
                          size: 38,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                color: RecyclingColors.deepForestGreen,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: category.binColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Bin: ${category.binColorName}',
                                style: TextStyle(
                                  color: category.binColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Common Items Section
                _buildSectionCard(
                  title: 'Common Items in This Category',
                  icon: Icons.checklist_rounded,
                  accentColor: RecyclingColors.deepForestGreen,
                  child: Column(
                    children: category.commonItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: RecyclingColors.forestGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Color(0xFF2D3748),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Step-by-Step Preparation Guide
                _buildSectionCard(
                  title: 'How to Prepare Before Disposal',
                  icon: Icons.cleaning_services_rounded,
                  accentColor: const Color(0xFF1976D2),
                  child: Column(
                    children: category.preparationSteps.asMap().entries.map((entry) {
                      final stepNum = entry.key + 1;
                      final stepText = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$stepNum',
                                style: const TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                stepText,
                                style: const TextStyle(
                                  color: Color(0xFF2D3748),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Do's and Don'ts Side-by-Side / Stacked
                _buildSectionCard(
                  title: 'Do\'s and Don\'ts',
                  icon: Icons.rule_rounded,
                  accentColor: RecyclingColors.forestGreen,
                  child: Column(
                    children: [
                      // Do's
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E9DD),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: RecyclingColors.lightSage),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: RecyclingColors.forestGreen,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'DO',
                                  style: TextStyle(
                                    color: RecyclingColors.forestGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...category.dos.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: RecyclingColors.forestGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            color: RecyclingColors.deepForestGreen,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Don'ts
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.cancel_rounded,
                                  color: Color(0xFFC62828),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'DON\'T',
                                  style: TextStyle(
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...category.donts.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Color(0xFFC62828),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            color: Color(0xFFB71C1C),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFECEFF1)),
          child,
        ],
      ),
    );
  }
}



