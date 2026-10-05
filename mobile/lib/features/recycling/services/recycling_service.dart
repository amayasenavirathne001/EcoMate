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

  static final List<MaterialItem> _masterMaterials = [];

  List<WasteCategory> _categories = [];

  static final List<RecyclingCenter> _centers = [];

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

  // Get master materials with is_active flag for the center
  Future<List<MaterialItem>> getCenterMaterialsForOfficer(String? officerEmail) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/recycling/my-center/materials'),
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
    final center = getCenterForOfficerLocal(officerEmail);
    if (center == null) return _masterMaterials;

    return _masterMaterials.map((mat) {
      final isAccepted = center.acceptedMaterials.contains(mat.name);
      return mat.copyWith(isActive: isAccepted);
    }).toList();
  }

  // Toggle single material is_active (1 or 0) in the mapping table
  Future<void> toggleMaterialStatus(int materialId, bool isActive) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.put(
          Uri.parse('$baseUrl/api/recycling/my-center/materials/toggle'),
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
          Uri.parse('$baseUrl/api/recycling/my-center'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final center = RecyclingCenter.fromJson(data);
          final idx = _centers.indexWhere((c) => c.id == center.id || c.officerEmail == email);
          if (idx >= 0) {
            _centers[idx] = center;
          } else {
            _centers.add(center);
          }
          return center;
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
      return _centers.firstWhere(
        (c) => c.officerEmail?.toLowerCase() == email.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOrUpdateCenter(RecyclingCenter center) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.put(
          Uri.parse('$baseUrl/api/recycling/my-center'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(center.toJson()),
        );
      } catch (_) {
        // Local fallback
      }
    }

    final index = _centers.indexWhere((c) => c.id == center.id);
    if (index >= 0) {
      _centers[index] = center;
    } else {
      _centers.add(center);
    }
  }

  Future<void> toggleCenterStatus(String centerId, bool isOpen) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.patch(
          Uri.parse('$baseUrl/api/recycling/my-center/status'),
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

    final index = _centers.indexWhere((c) => c.id == centerId);
    if (index >= 0) {
      _centers[index] = _centers[index].copyWith(isOpen: isOpen);
    }
  }

  List<RecyclingCenter> getRecyclingCenters({
    String? query,
    String? materialFilter,
  }) {
    List<RecyclingCenter> list = List.from(_centers);

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.trim().toLowerCase();
      list = list.where((center) {
        final matchesName = center.name.toLowerCase().contains(cleanQuery);
        final matchesCity = center.city.toLowerCase().contains(cleanQuery);
        final matchesAddr = center.address.toLowerCase().contains(cleanQuery);
        final matchesMat = center.acceptedMaterials.any(
          (m) => m.toLowerCase().contains(cleanQuery),
        );
        return matchesName || matchesCity || matchesAddr || matchesMat;
      }).toList();
    }

    if (materialFilter != null && materialFilter.isNotEmpty && materialFilter != 'All') {
      final filterLower = materialFilter.toLowerCase();
      list = list.where((center) {
        return center.acceptedMaterials.any(
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

    final uri = Uri.parse('$baseUrl/api/recycling/public/centers').replace(
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
            final idx = _centers.indexWhere((existing) => existing.id == c.id);
            if (idx >= 0) {
              _centers[idx] = c;
            } else {
              _centers.add(c);
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

  Future<RecyclingCenter?> createCenter(RecyclingCenter center) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/recycling/centers'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(center.toJson()),
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final created = RecyclingCenter.fromJson(data);
          _centers.add(created);
          return created;
        }
      } catch (_) {
        // Fallback
      }
    }
    _centers.add(center);
    return center;
  }

  Future<bool> deleteCenter(String id) async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/api/recycling/centers/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          _centers.removeWhere((c) => c.id == id);
          return true;
        }
      } catch (_) {}
    }
    _centers.removeWhere((c) => c.id == id);
    return true;
  }

  Future<List<WasteDeliveryRecord>> fetchDeliveries({String? centerId}) async {
    final token = await _authService.getToken();
    final url = centerId != null
        ? '$baseUrl/api/recycling/deliveries?centerId=$centerId'
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
        recyclingCenterId: '1',
        recyclingCenterName: 'GreenCycle Central center',
        materialType: 'Plastic Bottles (PET #1)',
        weightKg: 2.5,
        deliveredBy: 'Resident User',
        contactNumber: '0712345678',
        notes: 'Clean PET bottles',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WasteDeliveryRecord(
        id: 'DEL-102',
        recyclingCenterId: '2',
        recyclingCenterName: 'BioRecycle Organic Composting Plant',
        materialType: 'Organic',
        weightKg: 5.0,
        deliveredBy: 'Resident User',
        contactNumber: '0712345678',
        notes: 'Kitchen scraps',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
      ),
      WasteDeliveryRecord(
        id: 'DEL-103',
        recyclingCenterId: '1',
        recyclingCenterName: 'GreenCycle Central center',
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
      return _centers.firstWhere((c) => c.id == id);
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























