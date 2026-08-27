import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WasteReportService {
  static const _storage = FlutterSecureStorage();
  static const baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> submitReport({
    required String issueType,
    required String location,
    required String category,
    required String description,
    double? latitude,
    double? longitude,
    String? photoData,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Please log in before submitting a report.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/resident/reports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'issueType': issueType,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'wasteCategory': category,
        'description': description,
        'photoData': photoData,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your session has expired. Please log in again.');
    }
    throw Exception('Could not submit report (${response.statusCode}).');
  }

  Future<List<Map<String, dynamic>>> getMyReports() async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/api/resident/reports'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Could not load your reports.');
    }
    return (jsonDecode(response.body) as List)
        .cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getAdminReports() async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Please log in first.');
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/reports'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception('Could not load reports.');
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> updateAdminReport({
    required int id,
    required String status,
    required String priority,
    required String assignedTeam,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Please log in first.');
    final response = await http.put(
      Uri.parse('$baseUrl/api/municipal/reports/$id'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status, 'priority': priority, 'assignedTeam': assignedTeam}),
    );
    if (response.statusCode != 200) throw Exception('Could not update report.');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
