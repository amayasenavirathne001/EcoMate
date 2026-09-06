import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/auth_service.dart';
import '../models/smart_alert_model.dart';

class SmartAlertService {
  final AuthService _authService = AuthService();
  static const String baseUrl = AuthService.baseUrl;

  Future<List<SmartAlert>> getAllAlerts() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/municipal/alerts'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => SmartAlert.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching alerts: $e');
    }
    return getMockAlerts();
  }
  
  Future<List<SmartAlert>> getActiveAlerts() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/municipal/alerts/active'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => SmartAlert.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching active alerts: $e');
    }
    return getMockAlerts().where((a) => a.status != 'RESOLVED').toList();
  }

  Future<void> updateAlertStatus(int id, String status) async {
    try {
      final token = await _authService.getToken();
      await http.put(
        Uri.parse('$baseUrl/api/municipal/alerts/$id/status?status=$status'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      print('Error updating alert: $e');
    }
  }

  List<SmartAlert> getMockAlerts() {
    return [
      SmartAlert(
        id: 1,
        type: 'DELAYED_COLLECTION',
        severity: 'WARNING',
        jobId: 101,
        routeId: 'RT-001',
        zone: 'Zone A',
        description: 'Collection is running 45 minutes behind schedule.',
        createdTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        updatedTimestamp: DateTime.now(),
        status: 'ACTIVE',
      ),
      SmartAlert(
        id: 2,
        type: 'UNASSIGNED_COLLECTION',
        severity: 'CRITICAL',
        jobId: 102,
        routeId: 'RT-002',
        zone: 'Zone B',
        description: 'Job starts in 1 hour but has no assigned collectors.',
        createdTimestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedTimestamp: DateTime.now(),
        status: 'ACTIVE',
      ),
      SmartAlert(
        id: 3,
        type: 'MISSED_COLLECTION',
        severity: 'CRITICAL',
        jobId: 99,
        routeId: 'RT-003',
        zone: 'Zone C',
        description: 'Collection window ended and job is not complete.',
        createdTimestamp: DateTime.now().subtract(const Duration(hours: 3)),
        updatedTimestamp: DateTime.now(),
        status: 'RESOLVED',
      ),
    ];
  }
}
