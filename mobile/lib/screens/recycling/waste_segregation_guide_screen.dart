import 'package:flutter/material.dart';
import '../../models/waste_category.dart';
import '../../services/recycling_service.dart';
import 'category_detail_screen.dart';

class WasteSegregationGuideScreen extends StatefulWidget {
  const WasteSegregationGuideScreen({super.key});

  @override
  State<WasteSegregationGuideScreen> createState() =>
      _WasteSegregationGuideScreenState();
}

class _WasteSegregationGuideScreenState
    extends State<WasteSegregationGuideScreen> {
  final RecyclingService _recyclingService = RecyclingService();
  final TextEditingController _searchController = TextEditingController();

  List<WasteCategory> _displayedCategories = [];
  String _selectedFilter = 'All'; // 'All', 'Recyclable', 'Non-Recyclable'

  @override
  void initState() {
    super.initState();
    _displayedCategories = _recyclingService.getWasteCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final results = _recyclingService.searchCategoriesAndItems(query);
    setState(() {
      if (_selectedFilter == 'Recyclable') {
        _displayedCategories = results.where((c) => c.isRecyclable).toList();
      } else if (_selectedFilter == 'Non-Recyclable') {
        _displayedCategories = results.where((c) => !c.isRecyclable).toList();
      } else {
        _displayedCategories = results;
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _onSearchChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F5520), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Waste Segregation Guide',
          style: TextStyle(
            color: Color(0xFF1F5520),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Top Search & Filter Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Search Input
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(color: Color(0xFF2D3748)),
                        decoration: InputDecoration(
                          hintText: 'Search waste (e.g. bottle, battery, paper)...',
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF2E7D32),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF8FAF7),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFD9E3DA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFD9E3DA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2E7D32),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Filter chips
                      Row(
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Recyclable'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Non-Recyclable'),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE0E0E0)),

                // Category List
                Expanded(
                  child: _displayedCategories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 56,
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No matching waste categories found',
                                style: TextStyle(
                                  color: Color(0xFF69756D),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _displayedCategories.length,
                          itemBuilder: (context, index) {
                            final category = _displayedCategories[index];
                            return _buildCategoryCard(category);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(label),
      selectedColor: const Color(0xFF1F5520),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF1F5520) : const Color(0xFFD9E3DA),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF69756D),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildCategoryCard(WasteCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetailScreen(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon + Name + Recyclable Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.binColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.binColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: Color(0xFF1F5520),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: category.binColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category.binColorName,
                                style: const TextStyle(
                                  color: Color(0xFF69756D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: category.isRecyclable
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category.isRecyclable ? 'Recyclable' : 'Special Disposal',
                        style: TextStyle(
                          color: category.isRecyclable
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  category.description,
                  style: const TextStyle(
                    color: Color(0xFF69756D),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // Common items chips preview
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: category.commonItems.take(3).map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD9E3DA)),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF2D3748),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Footer: Tap to view details link
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Preparation Rules',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF2E7D32),
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}