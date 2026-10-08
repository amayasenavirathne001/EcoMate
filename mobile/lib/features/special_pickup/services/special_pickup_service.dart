import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../services/auth_service.dart';
import '../models/special_pickup.dart';

class SpecialPickupService {
  final AuthService _authService = AuthService();

  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ---------------------------------------------------------
  // GET AVAILABLE SPECIAL PICKUPS
  // GET /api/special-pickups
  // ---------------------------------------------------------

  Future<List<SpecialPickup>> getAvailablePickups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/special-pickups'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (json) => SpecialPickup.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'You are not authorized to view special pickups.',
      );
    }

    throw Exception(
      'Failed to load special pickups: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // ---------------------------------------------------------
  // GET ONE SPECIAL PICKUP
  // GET /api/special-pickups/{id}
  // ---------------------------------------------------------

  Future<SpecialPickup> getPickupById(int pickupId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/special-pickups/$pickupId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return SpecialPickup.fromJson(data);
    }

    if (response.statusCode == 404) {
      throw Exception('Special pickup not found.');
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'You are not authorized to view this special pickup.',
      );
    }

    throw Exception(
      'Failed to load special pickup: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // ---------------------------------------------------------
  // JOIN SPECIAL PICKUP
  // POST /api/special-pickups/{id}/join
  // ---------------------------------------------------------

  Future<Map<String, dynamic>> joinSpecialPickup({
    required int pickupId,
    required String wasteType,
    required int numberOfItems,
    required String estimatedSize,
    required double estimatedWeightKg,
    required double estimatedVolumeM3,
    required String pickupAddress,
    String? notes,
    String? photoUrl,
  }) async {
    final Map<String, dynamic> body = {
      'wasteType': wasteType,
      'numberOfItems': numberOfItems,
      'estimatedSize': estimatedSize,
      'estimatedWeightKg': estimatedWeightKg,
      'estimatedVolumeM3': estimatedVolumeM3,
      'pickupAddress': pickupAddress,
      'notes': notes,
      'photoUrl': photoUrl,
    };

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/special-pickups/$pickupId/join',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return jsonDecode(response.body)
          as Map<String, dynamic>;
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'You are not authorized to join this special pickup.',
      );
    }

    // Try to show the backend validation message.
    try {
      final dynamic errorData = jsonDecode(response.body);

      if (errorData is Map<String, dynamic>) {
        final message =
            errorData['message'] ??
            errorData['error'];

        if (message != null) {
          throw Exception(message.toString());
        }
      }
    } catch (e) {
      if (e is Exception &&
          e.toString() != 'Exception: null') {
        rethrow;
      }
    }

    throw Exception(
      'Unable to join special pickup: '
      '${response.statusCode} - ${response.body}',
    );
  }
}