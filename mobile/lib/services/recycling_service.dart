import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/material_item.dart';
import '../models/recycling_centre.dart';
import '../models/waste_category.dart';
import 'auth_service.dart';

class RecyclingService {
  static const String baseUrl = 'http://localhost:8080';
  final AuthService _authService = AuthService();

  static final List<MaterialItem> _masterMaterials = [
    const MaterialItem(
      id: 1,
      name: 'Plastic Bottles (PET #1)',
      category: 'Plastics',
      description: 'Clean transparent water & soda beverage bottles',
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=300',
      binColor: '#F59E0B',
      isRecyclable: true,
      preparationTips: 'Rinse with clean water, remove cap, and crush flat.',
    ),
    const MaterialItem(
      id: 2,
      name: 'Rigid Plastics (HDPE #2, PP #5)',
      category: 'Plastics',
      description: 'Detergent jugs, milk bottles, and shampoo containers',
      imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=300',
      binColor: '#F59E0B',
      isRecyclable: true,
      preparationTips: 'Empty completely and rinse out chemical residue.',
    ),
    const MaterialItem(
      id: 3,
      name: 'Cardboard & Office Paper',
      category: 'Paper & Cardboard',
      description: 'Corrugated boxes, plain writing paper, and notebooks',
      imageUrl: 'https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=300',
      binColor: '#3B82F6',
      isRecyclable: true,
      preparationTips: 'Flatten all boxes and keep dry.',
    ),
    const MaterialItem(
      id: 4,
      name: 'Newspapers & Magazines',
      category: 'Paper & Cardboard',
      description: 'Daily newspapers, printed magazines, and flyers',
      imageUrl: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=300',
      binColor: '#3B82F6',
      isRecyclable: true,
      preparationTips: 'Bundle securely with natural string or place in paper bags.',
    ),
    const MaterialItem(
      id: 5,
      name: 'Aluminum Beverage Cans',
      category: 'Metals',
      description: 'Clean soda, juice, and energy drink cans',
      imageUrl: 'https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=300',
      binColor: '#64748B',
      isRecyclable: true,
      preparationTips: 'Rinse out liquid residue and crush to save space.',
    ),
    const MaterialItem(
      id: 6,
      name: 'Steel & Tin Food Cans',
      category: 'Metals',
      description: 'Canned vegetables, soup, and fish tins',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300',
      binColor: '#64748B',
      isRecyclable: true,
      preparationTips: 'Rinse clean and push the metal lid safely inside.',
    ),
    const MaterialItem(
      id: 7,
      name: 'Glass Bottles & Jars',
      category: 'Glass',
      description: 'Clear, amber, and green glass condiment bottles & jars',
      imageUrl: 'https://images.unsplash.com/photo-1516962215378-7fa2e137ae93?w=300',
      binColor: '#10B981',
      isRecyclable: true,
      preparationTips: 'Rinse clean. Do not include window glass or mirrors.',
    ),
    const MaterialItem(
      id: 8,
      name: 'Mobile Phones & Tablets',
      category: 'E-Waste',
      description: 'Old handheld smartphones, feature phones, and tablets',
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300',
      binColor: '#8B5CF6',
      isRecyclable: true,
      preparationTips: 'Perform a factory reset to erase personal data.',
    ),
    const MaterialItem(
      id: 9,
      name: 'Computers & Laptops',
      category: 'E-Waste',
      description: 'Desktops, monitors, laptops, and hard drives',
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=300',
      binColor: '#8B5CF6',
      isRecyclable: true,
      preparationTips: 'Bundle cords and cables neatly with ties.',
    ),
    const MaterialItem(
      id: 10,
      name: 'Batteries & Power Banks',
      category: 'E-Waste',
      description: 'Rechargeable power packs, lithium-ion laptop batteries',
      imageUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=300',
      binColor: '#8B5CF6',
      isRecyclable: true,
      preparationTips: 'Tape positive/negative terminals with electrical tape.',
    ),
    const MaterialItem(
      id: 11,
      name: 'Cables & Small Appliances',
      category: 'E-Waste',
      description: 'Kettles, toasters, chargers, and power adapters',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=300',
      binColor: '#8B5CF6',
      isRecyclable: true,
      preparationTips: 'Unplug from wall and bundle cords securely.',
    ),
    const MaterialItem(
      id: 12,
      name: 'Fruit & Vegetable Scraps',
      category: 'Organic',
      description: 'Kitchen peels, vegetable cuttings, and fruit cores',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300',
      binColor: '#22C55E',
      isRecyclable: true,
      preparationTips: 'Separate from plastic packaging before depositing.',
    ),
    const MaterialItem(
      id: 13,
      name: 'Garden Leaves & Grass Clippings',
      category: 'Organic',
      description: 'Dry garden leaves, pruned branches, and grass cuttings',
      imageUrl: 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=300',
      binColor: '#22C55E',
      isRecyclable: true,
      preparationTips: 'Ensure free of stones, plastics, and non-biodegradable trash.',
    ),
    const MaterialItem(
      id: 14,
      name: 'Copper Wires & Brass Fittings',
      category: 'Scrap Metal',
      description: 'Household electrical wiring and plumbing brass scrap',
      imageUrl: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=300',
      binColor: '#D97706',
      isRecyclable: true,
      preparationTips: 'Strip thick outer rubber insulation if requested by centre.',
    ),
    const MaterialItem(
      id: 15,
      name: 'Old Metal Cookware',
      category: 'Scrap Metal',
      description: 'Worn aluminum pots, cast iron pans, and steel trays',
      imageUrl: 'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=300',
      binColor: '#D97706',
      isRecyclable: true,
      preparationTips: 'Scrape off food grease before drop-off.',
    ),
  ];

  static const List<WasteCategory> _categories = [
    WasteCategory(
      id: 'plastics',
      name: 'Plastics',
      binColorName: 'Orange / Yellow Bin',
      binColor: Color(0xFFF59E0B),
      icon: Icons.local_drink_rounded,
      description:
          'Clean and dry recyclable plastics such as bottles, containers, and rigid packaging.',
      isRecyclable: true,
      commonItems: [
        'PET Water & Soda Bottles (#1)',
        'HDPE Milk & Detergent Jugs (#2)',
        'PP Food Containers & Tubs (#5)',
        'Plastic bottle caps (attached)',
        'Clean plastic cosmetic bottles',
      ],
      preparationSteps: [
        'Empty all liquids and contents completely.',
        'Rinse thoroughly with clean water to remove food residue.',
        'Crush or compress plastic bottles to save bin space.',
        'Keep caps screwed onto the bottle or place loose inside.',
      ],
      dos: [
        'Rinse items thoroughly before disposal',
        'Check resin identification codes (#1, #2, #5)',
        'Flatten plastic bottles to maximize space',
      ],
      donts: [
        'Do not recycle plastic bags, cling film, or grocery poly-bags',
        'Do not recycle dirty or oil-stained takeout containers',
        'Do not recycle polystyrene foam (Styrofoam)',
      ],
    ),
    WasteCategory(
      id: 'paper',
      name: 'Paper & Cardboard',
      binColorName: 'Blue Bin',
      binColor: Color(0xFF3B82F6),
      icon: Icons.article_rounded,
      description:
          'Dry, clean paper, cardboard boxes, newspapers, and non-waxed cartons.',
      isRecyclable: true,
      commonItems: [
        'Corrugated shipping & parcel boxes',
        'Cereal & dry food packaging boxes',
        'Newspapers, magazines, and flyers',
        'Office printer paper and envelopes',
        'Egg cartons (clean paperboard)',
      ],
      preparationSteps: [
        'Flatten all cardboard boxes completely.',
        'Remove any plastic packing tape and polystyrene inside.',
        'Keep dry â€” wet paper cannot be processed at recycling plants.',
      ],
      dos: [
        'Flatten cardboard boxes to save space',
        'Keep all paper items dry and clean',
        'Separate plastic windows from mail envelopes if possible',
      ],
      donts: [
        'Do not include greasy pizza boxes or oil-stained paper',
        'Do not include wax-coated beverage cups or cartons',
        'Do not include used paper towels, tissues, or napkins',
      ],
    ),
    WasteCategory(
      id: 'glass',
      name: 'Glass',
      binColorName: 'Green Bin',
      binColor: Color(0xFF10B981),
      icon: Icons.wine_bar_rounded,
      description:
          'Intact glass bottles, beverage containers, and food jars (clear, brown, green).',
      isRecyclable: true,
      commonItems: [
        'Glass beverage & soda bottles',
        'Glass jam, sauce, and pickle jars',
        'Glass condiment & oil bottles',
        'Glass cosmetic jars (rinsed)',
      ],
      preparationSteps: [
        'Rinse thoroughly to remove all food and sauce traces.',
        'Remove metal or plastic caps and lids (recycle separately).',
        'Do not break â€” keep glass containers intact for safety.',
      ],
      dos: [
        'Rinse jars and bottles thoroughly',
        'Recycle metal lids separately with metals',
        'Place gently into the bin to prevent shattering',
      ],
      donts: [
        'Do not recycle broken window panes or mirrors',
        'Do not recycle drinking glasses, mugs, or crystalware',
        'Do not recycle ceramic plates, tiles, or heat-resistant Pyrex',
      ],
    ),
    WasteCategory(
      id: 'metals',
      name: 'Metals & Cans',
      binColorName: 'Silver / Grey Bin',
      binColor: Color(0xFF64748B),
      icon: Icons.takeout_dining_rounded,
      description:
          'Aluminum cans, steel food tins, clean foil trays, and clean metal jar lids.',
      isRecyclable: true,
      commonItems: [
        'Aluminum beverage & soda cans',
        'Steel/tin soup, fish, and vegetable cans',
        'Clean aluminum foil and baking trays',
        'Metal bottle caps and jar lids',
        'Empty aerosol spray cans (completely discharged)',
      ],
      preparationSteps: [
        'Rinse clean of all sauces, liquids, and oils.',
        'Crush beverage cans to save bin volume.',
        'Push metal lids inside the cans for safety.',
      ],
      dos: [
        'Rinse all food and beverage cans',
        'Crush aluminum cans to maximize space',
        'Ensure aerosol cans are 100% empty and depressurized',
      ],
      donts: [
        'Do not include gas cylinders or propane tanks',
        'Do not include paint cans containing wet paint',
        'Do not include sharp knives, wires, or automotive scrap',
      ],
    ),
    WasteCategory(
      id: 'organic',
      name: 'Organic & Food Waste',
      binColorName: 'Green Compost Bin',
      binColor: Color(0xFF22C55E),
      icon: Icons.eco_rounded,
      description:
          'Biodegradable kitchen scraps, fruit peels, leftover cooked food, and yard trimmings.',
      isRecyclable: true,
      commonItems: [
        'Fruit and vegetable peels & scraps',
        'Coffee grounds and unbleached paper filters',
        'Eggshells and nut shells',
        'Leftover cooked rice, bread, and grains',
        'Garden leaves, cut grass, and small pruned twigs',
      ],
      preparationSteps: [
        'Drain excess liquids and gravy from food scraps.',
        'Collect in a compostable bag or dedicated organic bin.',
        'Place in municipal compost bin or home compost unit.',
      ],
      dos: [
        'Collect fruit and vegetable peels daily',
        'Drain watery liquids before disposing',
        'Use compostable bags where available',
      ],
      donts: [
        'Do not mix plastic wrappers or polythene with food waste',
        'Avoid large animal bones in municipal compost bins',
        'Do not include treated or painted wood in organic waste',
      ],
    ),
    WasteCategory(
      id: 'ewaste',
      name: 'Electronic Waste (E-Waste)',
      binColorName: 'Designated E-Waste Drop-off',
      binColor: Color(0xFF8B5CF6),
      icon: Icons.devices_other_rounded,
      description:
          'Disused electrical items, computers, mobile phones, batteries, and accessories.',
      isRecyclable: true,
      commonItems: [
        'Mobile Phones & Tablets',
        'Chargers, USB Cables & Power Banks',
        'Laptops & Desktop Components',
        'Keyboards, Mice & Small Appliances',
        'Printers & Ink Cartridges',
      ],
      preparationSteps: [
        'Perform a factory reset and remove personal data from devices.',
        'Bundle cords and cables neatly with a rubber band.',
        'Drop off at an authorized E-Waste recycling center.',
      ],
      dos: [
        'Take items to designated e-waste drop-off kiosks or recycling centers',
        'Remove rechargeable batteries if removable',
        'Keep electronics dry and sheltered from rain',
      ],
      donts: [
        'Do not throw electronics into regular municipal garbage bins',
        'Do not dismantle or break screens and tubes yourself',
        'Do not burn electronic cables or circuits',
      ],
    ),
  ];

  static final List<RecyclingCentre> _centres = [
    const RecyclingCentre(
      id: '1',
      officerId: 14,
      officerEmail: 'stharanga.rog@gmail.com',
      name: 'GreenCycle Central Hub',
      address: 'No. 45 Baseline Road, Colombo 09',
      city: 'Colombo',
      distanceKm: 1.2,
      contactNumber: '+94 11 268 4590',
      email: 'contact@greencyclehub.lk',
      operatingHours: 'Mon - Sat: 8:00 AM - 5:30 PM',
      isOpen: true,
      acceptedMaterials: [
        'Plastic Bottles (PET #1)',
        'Rigid Plastics (HDPE #2, PP #5)',
        'Cardboard & Office Paper',
        'Aluminum Beverage Cans',
        'Glass Bottles & Jars',
      ],
      unsupportedMaterials: [
        'Newspapers & Magazines',
        'Steel & Tin Food Cans',
        'Mobile Phones & Tablets',
        'Computers & Laptops',
        'Batteries & Power Banks',
        'Cables & Small Appliances',
        'Fruit & Vegetable Scraps',
        'Garden Leaves & Grass Clippings',
        'Copper Wires & Brass Fittings',
        'Old Metal Cookware',
      ],
      notes:
          'Offers drop-off points for bulk recyclables. Weight-based incentives provided.',
    ),
    const RecyclingCentre(
      id: '2',
      officerId: 4,
      officerEmail: 'sumudu@gmail.com',
      name: 'BioRecycle Organic Composting Plant',
      address: '88 Temple Road, Nawala, Rajagiriya',
      city: 'Rajagiriya',
      distanceKm: 4.5,
      contactNumber: '+94 11 442 1102',
      email: 'support@biorecycle.org',
      operatingHours: 'Mon - Fri: 7:30 AM - 4:00 PM',
      isOpen: true,
      acceptedMaterials: [
        'Fruit & Vegetable Scraps',
        'Garden Leaves & Grass Clippings',
        'Cardboard & Office Paper',
      ],
      unsupportedMaterials: [
        'Plastic Bottles (PET #1)',
        'Rigid Plastics (HDPE #2, PP #5)',
        'Aluminum Beverage Cans',
        'Glass Bottles & Jars',
        'Mobile Phones & Tablets',
      ],
      notes:
          'Free organic compost bag exchange for every 10kg of kitchen waste delivered.',
    ),
    const RecyclingCentre(
      id: '3',
      officerId: 7,
      officerEmail: 'peterparkerr@gmail.com',
      name: 'EcoTech E-Waste Recovery Centre',
      address: '120 High Level Road, Maharagama',
      city: 'Maharagama',
      distanceKm: 3.8,
      contactNumber: '+94 11 285 9940',
      email: 'info@ecotech-recovery.lk',
      operatingHours: 'Tue - Sun: 9:00 AM - 6:00 PM',
      isOpen: true,
      acceptedMaterials: [
        'Mobile Phones & Tablets',
        'Computers & Laptops',
        'Batteries & Power Banks',
        'Cables & Small Appliances',
      ],
      unsupportedMaterials: [
        'Plastic Bottles (PET #1)',
        'Cardboard & Office Paper',
        'Fruit & Vegetable Scraps',
        'Glass Bottles & Jars',
      ],
      notes:
          'Specialized authorized e-waste facility. Free certified data wiping on computer drives.',
    ),
  ];

  List<WasteCategory> getWasteCategories() {
    return _categories;
  }

  List<WasteCategory> filterCategories({required bool onlyRecyclable}) {
    return _categories.where((c) => c.isRecyclable == onlyRecyclable).toList();
  }

  List<WasteCategory> searchCategoriesAndItems(String query) {
    if (query.trim().isEmpty) return _categories;
    final q = query.trim().toLowerCase();
    return _categories.where((cat) {
      final matchCatName = cat.name.toLowerCase().contains(q);
      final matchDesc = cat.description.toLowerCase().contains(q);
      final matchItem = cat.commonItems.any((item) => item.toLowerCase().contains(q));
      return matchCatName || matchDesc || matchItem;
    }).toList();
  }

  List<MaterialItem> getMasterMaterialList() {
    return _masterMaterials;
  }

  // Get master materials with is_active flag for the centre
  Future<List<MaterialItem>> getCentreMaterialsForOfficer(String? officerEmail) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/recycling/my-centre/materials'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return list.map((item) => MaterialItem.fromJson(item as Map<String, dynamic>)).toList();
        }
      } catch (_) {
        // Backend offline fallback
      }
    }

    // Local fallback
    final centre = getCentreForOfficerLocal(officerEmail);
    if (centre == null) return _masterMaterials;

    return _masterMaterials.map((mat) {
      final isAccepted = centre.acceptedMaterials.contains(mat.name);
      return mat.copyWith(isActive: isAccepted);
    }).toList();
  }

  // Toggle single material is_active (1 or 0) in the mapping table
  Future<void> toggleMaterialStatus(int materialId, bool isActive) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.put(
          Uri.parse('$baseUrl/api/recycling/my-centre/materials/toggle'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'materialId': materialId,
            'isActive': isActive,
          }),
        );
      } catch (_) {
        // Local fallback
      }
    }
  }

  Future<RecyclingCentre?> getCentreForOfficer(String? email) async {
    if (email == null || email.isEmpty) return null;

    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/recycling/my-centre'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final centre = RecyclingCentre.fromJson(data);
          final idx = _centres.indexWhere((c) => c.id == centre.id || c.officerEmail == email);
          if (idx >= 0) {
            _centres[idx] = centre;
          } else {
            _centres.add(centre);
          }
          return centre;
        }
      } catch (_) {
        // Backend offline fallback
      }
    }

    return getCentreForOfficerLocal(email);
  }

  RecyclingCentre? getCentreForOfficerLocal(String? email) {
    if (email == null || email.isEmpty) return null;
    try {
      return _centres.firstWhere(
        (c) => c.officerEmail?.toLowerCase() == email.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOrUpdateCentre(RecyclingCentre centre) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.put(
          Uri.parse('$baseUrl/api/recycling/my-centre'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(centre.toJson()),
        );
      } catch (_) {
        // Local fallback
      }
    }

    final index = _centres.indexWhere((c) => c.id == centre.id);
    if (index >= 0) {
      _centres[index] = centre;
    } else {
      _centres.add(centre);
    }
  }

  Future<void> toggleCentreStatus(String centreId, bool isOpen) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.patch(
          Uri.parse('$baseUrl/api/recycling/my-centre/status'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'isOpen': isOpen}),
        );
      } catch (_) {
        // Local fallback
      }
    }

    final index = _centres.indexWhere((c) => c.id == centreId);
    if (index >= 0) {
      _centres[index] = _centres[index].copyWith(isOpen: isOpen);
    }
  }

  List<RecyclingCentre> getRecyclingCentres({
    String? query,
    String? materialFilter,
  }) {
    List<RecyclingCentre> list = List.from(_centres);

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.trim().toLowerCase();
      list = list.where((centre) {
        final matchesName = centre.name.toLowerCase().contains(cleanQuery);
        final matchesCity = centre.city.toLowerCase().contains(cleanQuery);
        final matchesAddr = centre.address.toLowerCase().contains(cleanQuery);
        final matchesMat = centre.acceptedMaterials.any(
          (m) => m.toLowerCase().contains(cleanQuery),
        );
        return matchesName || matchesCity || matchesAddr || matchesMat;
      }).toList();
    }

    if (materialFilter != null && materialFilter.isNotEmpty && materialFilter != 'All') {
      final filterLower = materialFilter.toLowerCase();
      list = list.where((centre) {
        return centre.acceptedMaterials.any(
          (mat) => mat.toLowerCase().contains(filterLower),
        );
      }).toList();
    }

    return list;
  }

  RecyclingCentre? getCentreById(String id) {
    try {
      return _centres.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}