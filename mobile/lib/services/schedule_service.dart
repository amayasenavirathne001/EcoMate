import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/schedule_models.dart';
import '../models/recycling_centre.dart';

class ScheduleService {
  final AuthService _authService = AuthService();
  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // --- Routes ---
  Future<List<RouteModel>> getRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/routes'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RouteModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load routes: ${response.statusCode}');
  }

  Future<RouteModel> createRoute(Map<String, dynamic> routeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/routes'),
      headers: await _getHeaders(),
      body: jsonEncode(routeData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create route: ${response.statusCode}');
  }

  Future<RouteModel> updateRoute(int id, Map<String, dynamic> routeData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/routes/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(routeData),
    );
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update route: ${response.statusCode}');
  }

  Future<RouteModel> updateRouteStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/routes/$id/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update route status: ${response.statusCode}');
  }

  // --- Collection Schedules ---
  Future<List<CollectionScheduleModel>> getSchedules() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/collection-schedules'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CollectionScheduleModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load schedules: ${response.statusCode}');
  }

  Future<CollectionScheduleModel> getScheduleById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/collection-schedules/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return CollectionScheduleModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load schedule: ${response.statusCode}');
  }

  Future<CollectionScheduleModel> createSchedule(CollectionScheduleModel schedule) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/collection-schedules'),
      headers: await _getHeaders(),
      body: jsonEncode(schedule.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return CollectionScheduleModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create schedule: ${response.statusCode}');
  }

  Future<CollectionScheduleModel> updateSchedule(int id, CollectionScheduleModel schedule) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/collection-schedules/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(schedule.toJson()),
    );
    if (response.statusCode == 200) {
      return CollectionScheduleModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update schedule: ${response.statusCode}');
  }

  Future<CollectionScheduleModel> updateScheduleStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/collection-schedules/$id/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode == 200) {
      return CollectionScheduleModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update schedule status: ${response.statusCode}');
  }

  // --- Recycling Centers Filtering ---
  Future<List<RecyclingCentre>> getCompatibleCentres(String wasteCategoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recycling-centers/by-material/$wasteCategoryId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((rc) => RecyclingCentre(
        id: rc['id'] as String,
        name: rc['name'] as String? ?? '',
        address: rc['address'] as String? ?? '',
        city: rc['city'] as String? ?? '',
        distanceKm: (rc['distanceKm'] as num?)?.toDouble() ?? 0.0,
        contactNumber: rc['contactNumber'] as String? ?? '',
        email: rc['email'] as String? ?? '',
        operatingHours: rc['operatingHours'] as String? ?? '',
        isOpen: rc['open'] as bool? ?? true,
        acceptedMaterials: List<String>.from(rc['acceptedMaterials'] ?? []),
        unsupportedMaterials: List<String>.from(rc['unsupportedMaterials'] ?? []),
        notes: rc['notes'] as String? ?? '',
      )).toList();
    }
    throw Exception('Failed to load compatible centres: ${response.statusCode}');
  }
}
