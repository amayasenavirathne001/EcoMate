import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../services/auth_service.dart';
import '../../../special_pickup/models/special_pickup.dart';

class MunicipalSpecialPickupService {
  final AuthService _authService = AuthService();

  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<SpecialPickup>> getPickups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/special-pickups'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Invalid pickup response.');
      }

      return data
          .map(
            (item) => SpecialPickup.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load special pickups: '
      '${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createPickup({
    required int scheduleId,
    required DateTime pickupDate,
    required String title,
    required String description,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/special-pickups'),
      headers: await _headers(),
      body: jsonEncode({
        'scheduleId': scheduleId,
        'pickupDate': _dateOnly(pickupDate),
        'title': title,
        'description': description,
        'location': location,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return jsonDecode(response.body)
          as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to create special pickup: '
      '${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> assignTruck({
    required int pickupId,
    required int truckId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/admin/special-pickups/'
        '$pickupId/assign',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'truckId': truckId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)
          as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to assign truck: '
      '${response.statusCode} - ${response.body}',
    );
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/admin/special-pickup-schedules',
      ),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Invalid schedule response.');
      }

      return data
          .map(
            (item) =>
                Map<String, dynamic>.from(item as Map),
          )
          .toList();
    }

    throw Exception(
      'Failed to load schedules: '
      '${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createSchedule({
    required int routeId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required int maxHouseholds,
    required double maxWeightKg,
    required double maxVolumeM3,
    required int joinDeadlineHours,
    required String acceptedWasteTypes,
    int adminId = 1,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/admin/special-pickup-schedules'
        '?adminId=$adminId',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'routeId': routeId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'maxHouseholds': maxHouseholds,
        'maxWeightKg': maxWeightKg,
        'maxVolumeM3': maxVolumeM3,
        'joinDeadlineHours': joinDeadlineHours,
        'acceptedWasteTypes': acceptedWasteTypes,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return jsonDecode(response.body)
          as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to create schedule: '
      '${response.statusCode} - ${response.body}',
    );
  }

  Future<void> disableSchedule(int scheduleId) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/admin/special-pickup-schedules/'
        '$scheduleId/disable',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to disable schedule: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}