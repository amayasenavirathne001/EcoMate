import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:8080';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final headers = await _getHeaders();
    if (!headers.containsKey('Authorization')) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  Future<bool> markAsRead(int notificationId) async {
    final headers = await _getHeaders();
    if (!headers.containsKey('Authorization')) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
