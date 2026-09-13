import '../theme/recycling_colors.dart';
import 'package:flutter/material.dart';
import '../models/recycling_centre.dart';
import '../services/recycling_service.dart';
import 'centre_detail_screen.dart';

class RecyclingCentresScreen extends StatefulWidget {
  const RecyclingCentresScreen({super.key});

  @override
  State<RecyclingCentresScreen> createState() => _RecyclingCentresScreenState();
}

class _RecyclingCentresScreenState extends State<RecyclingCentresScreen> {
  final RecyclingService _recyclingService = RecyclingService();
  final TextEditingController _searchController = TextEditingController();

  List<RecyclingCentre> _displayedCentres = [];
  String _selectedMaterial = 'All';
  bool _isLoading = false;

  final List<String> _materialOptions = [
    'All',
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'E-Waste',
    'Organic',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCentres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCentres() async {
    setState(() => _isLoading = true);
    final centres = await _recyclingService.fetchRecyclingCentres(
      query: _searchController.text,
      materialFilter: _selectedMaterial,
    );
    if (mounted) {
      setState(() {
        _displayedCentres = centres;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecyclingColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: RecyclingColors.deepForestGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearby Recycling Centres',
          style: TextStyle(
            color: RecyclingColors.deepForestGreen,
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
                // Search and Material Filter Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Search Input
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => _fetchCentres(),
                        style: const TextStyle(color: Color(0xFF2D3748)),
                        decoration: InputDecoration(
                          hintText: 'Search by centre name, city, or address...',
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: RecyclingColors.forestGreen,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _fetchCentres();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: RecyclingColors.offWhite,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
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
                            borderSide: const BorderSide(
                              color: RecyclingColors.forestGreen,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Material Horizontal Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _materialOptions.map((mat) {
                            final isSelected = _selectedMaterial == mat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(mat),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedMaterial = mat;
                                  });
                                  _fetchCentres();
                                },
                                selectedColor: RecyclingColors.deepForestGreen,
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected
                                      ? RecyclingColors.deepForestGreen
                                      : RecyclingColors.cardBorder,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : RecyclingColors.earthyBrown,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE0E0E0)),

                // Centres List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: RecyclingColors.deepForestGreen),
                        )
                      : _displayedCentres.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off_rounded,
                                    size: 56,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No recycling centres found matching your search',
                                    style: TextStyle(
                                      color: RecyclingColors.earthyBrown,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _displayedCentres.length,
                              itemBuilder: (context, index) {
                                final centre = _displayedCentres[index];
                                return _buildCentreCard(centre);
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

  Widget _buildCentreCard(RecyclingCentre centre) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RecyclingColors.cardBorder),
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
                builder: (_) => CentreDetailScreen(centre: centre),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Name + Open/Closed Badge + Distance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E9DD),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_rounded,
                        color: RecyclingColors.forestGreen,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            centre.name,
                            style: const TextStyle(
                              color: RecyclingColors.deepForestGreen,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            centre.address,
                            style: const TextStyle(
                              color: RecyclingColors.earthyBrown,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: centre.isOpen
                                ? const Color(0xFFE5E9DD)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            centre.isOpen ? 'OPEN' : 'CLOSED',
                            style: TextStyle(
                              color: centre.isOpen
                                  ? RecyclingColors.forestGreen
                                  : const Color(0xFFC62828),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_walk_rounded,
                              size: 14,
                              color: Color(0xFF1976D2),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${centre.distanceKm} km',
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Operating Hours Row
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: RecyclingColors.earthyBrown,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      centre.operatingHours,
                      style: const TextStyle(
                        color: RecyclingColors.earthyBrown,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Accepted Materials Chips Preview
                const Text(
                  'Accepted Materials:',
                  style: TextStyle(
                    color: RecyclingColors.forestGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: centre.acceptedMaterials.take(4).map((mat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E9DD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: RecyclingColors.lightSage),
                      ),
                      child: Text(
                        mat,
                        style: const TextStyle(
                          color: RecyclingColors.deepForestGreen,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}