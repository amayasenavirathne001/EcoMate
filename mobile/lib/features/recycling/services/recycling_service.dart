import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/material_item.dart';
import '../models/recycling_center.dart';
import '../models/waste_delivery_record.dart';
import '../../../models/waste_category.dart';
import '../../../services/auth_service.dart';

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
      preparationTips: 'Strip thick outer rubber insulation if requested by Center.',
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

  List<WasteCategory> _categories = [];

  static final List<RecyclingCenter> _Centers = [
    const RecyclingCenter(
      id: '1',
      officerId: 14,
      officerEmail: 'stharanga.rog@gmail.com',
      name: 'GreenCycle Central Center',
      address: 'No. 45 Baseline Road, Colombo 09',
      city: 'Colombo',
      distanceKm: 1.2,
      contactNumber: '+94 11 268 4590',
      email: 'contact@greencyclecenter.lk',
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
    const RecyclingCenter(
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
    const RecyclingCenter(
      id: '3',
      officerId: 7,
      officerEmail: 'peterparkerr@gmail.com',
      name: 'EcoTech E-Waste Recovery Center',
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

    String _iconToStr(IconData icon) {
    if (icon == Icons.local_drink_rounded) return 'local_drink_rounded';
    if (icon == Icons.article_rounded) return 'article_rounded';
    if (icon == Icons.wine_bar_rounded) return 'wine_bar_rounded';
    if (icon == Icons.takeout_dining_rounded) return 'takeout_dining_rounded';
    if (icon == Icons.eco_rounded) return 'eco_rounded';
    if (icon == Icons.devices_other_rounded) return 'devices_other_rounded';
    if (icon == Icons.warning_rounded) return 'warning_rounded';
    return 'category_rounded';
  }

  Future<void> updateWasteCategory(WasteCategory category) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/waste-categories/${category.id}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': category.name,
        'recyclable': category.isRecyclable,
        'description': category.description,
        'binColorName': category.binColorName,
        'binColor': '0x${category.binColor.value.toRadixString(16).toUpperCase()}',
        'icon': _iconToStr(category.icon),
        'commonItems': category.commonItems,
        'preparationSteps': category.preparationSteps,
        'dos': category.dos,
        'donts': category.donts,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update category: ${response.body}');
    }

    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  Future<List<WasteCategory>> fetchWasteCategories() async {
    final token = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/waste-categories?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _categories = data.map((json) => WasteCategory.fromJson(json)).toList();
        return _categories;
      }
      return _categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return _categories;
    }
  }

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
  // Fetch all materials from council API
  Future<List<MaterialItem>> fetchAllMaterials() async {
    final token = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/council/materials'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => MaterialItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _masterMaterials;
  }

  // Get master materials with is_active flag for the Center
  Future<List<MaterialItem>> getCenterMaterialsForOfficer(String? officerEmail) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/recycling/my-Center/materials'),
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
    final Center = getCenterForOfficerLocal(officerEmail);
    if (Center == null) return _masterMaterials;

    return _masterMaterials.map((mat) {
      final isAccepted = Center.acceptedMaterials.contains(mat.name);
      return mat.copyWith(isActive: isAccepted);
    }).toList();
  }

  // Toggle single material is_active (1 or 0) in the mapping table
  Future<void> toggleMaterialStatus(int materialId, bool isActive) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.put(
          Uri.parse('$baseUrl/api/recycling/my-Center/materials/toggle'),
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

  Future<RecyclingCenter?> getCenterForOfficer(String? email) async {
    if (email == null || email.isEmpty) return null;

    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/recycling/my-Center'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final Center = RecyclingCenter.fromJson(data);
          final idx = _Centers.indexWhere((c) => c.id == Center.id || c.officerEmail == email);
          if (idx >= 0) {
            _Centers[idx] = Center;
          } else {
            _Centers.add(Center);
          }
          return Center;
        }
      } catch (_) {
        // Backend offline fallback
      }
    }

    return getCenterForOfficerLocal(email);
  }

  RecyclingCenter? getCenterForOfficerLocal(String? email) {
    if (email == null || email.isEmpty) return null;
    try {
      return _Centers.firstWhere(
        (c) => c.officerEmail?.toLowerCase() == email.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOrUpdateCenter(RecyclingCenter Center) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.put(
          Uri.parse('$baseUrl/api/recycling/my-Center'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(Center.toJson()),
        );
      } catch (_) {
        // Local fallback
      }
    }

    final index = _Centers.indexWhere((c) => c.id == Center.id);
    if (index >= 0) {
      _Centers[index] = Center;
    } else {
      _Centers.add(Center);
    }
  }

  Future<void> toggleCenterStatus(String CenterId, bool isOpen) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.patch(
          Uri.parse('$baseUrl/api/recycling/my-Center/status'),
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

    final index = _Centers.indexWhere((c) => c.id == CenterId);
    if (index >= 0) {
      _Centers[index] = _Centers[index].copyWith(isOpen: isOpen);
    }
  }

  List<RecyclingCenter> getRecyclingCenters({
    String? query,
    String? materialFilter,
  }) {
    List<RecyclingCenter> list = List.from(_Centers);

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.trim().toLowerCase();
      list = list.where((Center) {
        final matchesName = Center.name.toLowerCase().contains(cleanQuery);
        final matchesCity = Center.city.toLowerCase().contains(cleanQuery);
        final matchesAddr = Center.address.toLowerCase().contains(cleanQuery);
        final matchesMat = Center.acceptedMaterials.any(
          (m) => m.toLowerCase().contains(cleanQuery),
        );
        return matchesName || matchesCity || matchesAddr || matchesMat;
      }).toList();
    }

    if (materialFilter != null && materialFilter.isNotEmpty && materialFilter != 'All') {
      final filterLower = materialFilter.toLowerCase();
      list = list.where((Center) {
        return Center.acceptedMaterials.any(
          (mat) => mat.toLowerCase().contains(filterLower),
        );
      }).toList();
    }

    return list;
  }

  Future<List<RecyclingCenter>> fetchRecyclingCenters({
    String? query,
    String? materialFilter,
  }) async {
    final queryParams = <String, String>{};
    if (query != null && query.trim().isNotEmpty) {
      queryParams['query'] = query.trim();
    }
    if (materialFilter != null && materialFilter.isNotEmpty && materialFilter != 'All') {
      queryParams['material'] = materialFilter;
    }

    final uri = Uri.parse('$baseUrl/api/recycling/public/Centers').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final list = jsonDecode(response.body) as List<dynamic>;
        final fetchedCenters = list
            .map((item) => RecyclingCenter.fromJson(item as Map<String, dynamic>))
            .toList();
        if (fetchedCenters.isNotEmpty) {
          for (final c in fetchedCenters) {
            final idx = _Centers.indexWhere((existing) => existing.id == c.id);
            if (idx >= 0) {
              _Centers[idx] = c;
            } else {
              _Centers.add(c);
            }
          }
          return fetchedCenters;
        }
      }
    } catch (_) {
      // Fallback to local list on error
    }

    return getRecyclingCenters(query: query, materialFilter: materialFilter);
  }

  Future<RecyclingCenter?> createCenter(RecyclingCenter Center) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/recycling/Centers'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(Center.toJson()),
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final created = RecyclingCenter.fromJson(data);
          _Centers.add(created);
          return created;
        }
      } catch (_) {
        // Fallback
      }
    }
    _Centers.add(Center);
    return Center;
  }

  Future<bool> deleteCenter(String id) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/api/recycling/Centers/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          _Centers.removeWhere((c) => c.id == id);
          return true;
        }
      } catch (_) {}
    }
    _Centers.removeWhere((c) => c.id == id);
    return true;
  }

  Future<List<WasteDeliveryRecord>> fetchDeliveries({String? CenterId}) async {
    final token = await _authService.getToken();
    final url = CenterId != null
        ? '$baseUrl/api/recycling/deliveries?CenterId=$CenterId'
        : '$baseUrl/api/recycling/deliveries';

    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return list
              .map((item) => WasteDeliveryRecord.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // Backend offline fallback
      }
    }
    return [];
  }

  Future<WasteDeliveryRecord?> recordDelivery(WasteDeliveryRecord delivery) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/recycling/deliveries'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(delivery.toJson()),
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return WasteDeliveryRecord.fromJson(data);
        }
      } catch (_) {
        // Offline fallback
      }
    }
    return delivery;
  }

  Future<List<WasteDeliveryRecord>> fetchMyRecyclingHistory() async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/recycling/my-history'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return list
              .map((item) => WasteDeliveryRecord.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // Fallback below
      }
    }
    
    // Offline/Mock fallback for UI testing
    return [
      WasteDeliveryRecord(
        id: 'DEL-101',
        RecyclingCenterId: '1',
        RecyclingCenterName: 'GreenCycle Central Center',
        materialType: 'Plastic Bottles (PET #1)',
        weightKg: 2.5,
        deliveredBy: 'Resident User',
        contactNumber: '0712345678',
        notes: 'Clean PET bottles',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WasteDeliveryRecord(
        id: 'DEL-102',
        RecyclingCenterId: '2',
        RecyclingCenterName: 'BioRecycle Organic Composting Plant',
        materialType: 'Organic',
        weightKg: 5.0,
        deliveredBy: 'Resident User',
        contactNumber: '0712345678',
        notes: 'Kitchen scraps',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
      ),
      WasteDeliveryRecord(
        id: 'DEL-103',
        RecyclingCenterId: '1',
        RecyclingCenterName: 'GreenCycle Central Center',
        materialType: 'Cardboard',
        weightKg: 1.2,
        deliveredBy: 'Resident User',
        contactNumber: '0712345678',
        notes: 'Folded boxes',
        dateTime: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  RecyclingCenter? getCenterById(String id) {
    try {
      return _Centers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Update Processing Status (SCRUM-58)
  Future<bool> updateProcessingStatus(String deliveryId, String newStatus) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.patch(
          Uri.parse('$baseUrl/api/recycling/deliveries/$deliveryId/status'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'processingStatus': newStatus}),
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          return true;
        }
      } catch (e) {
        debugPrint('Error updating processing status: $e');
      }
    }
    
    // Fallback for mock data testing if backend is offline
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}













