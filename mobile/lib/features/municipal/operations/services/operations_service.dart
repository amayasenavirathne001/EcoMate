import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/auth_service.dart';
import '../models/operations_models.dart';

class OperationsService {
  final AuthService _authService = AuthService();
  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ================= Employee APIs =================

  Future<List<Employee>> getAllEmployees() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/employees'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Employee>> getActiveEmployeesByRole(String role) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/employees/role/$role'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active employees: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Employee> createEmployee(Employee employee) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/municipal/employees'),
      headers: headers,
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 201) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response.body);
      throw Exception(errorMsg);
    }
  }

  Future<Employee> updateEmployee(int id, Employee employee) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/municipal/employees/$id'),
      headers: headers,
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response.body);
      throw Exception(errorMsg);
    }
  }

  Future<void> deactivateEmployee(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/municipal/employees/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to deactivate employee: ${response.statusCode} - ${response.body}');
    }
  }

  // ================= Vehicle APIs =================

  Future<List<Vehicle>> getAllVehicles() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/vehicles'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/municipal/vehicles'),
      headers: headers,
      body: jsonEncode(vehicle.toJson()),
    );

    if (response.statusCode == 201) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response.body);
      throw Exception(errorMsg);
    }
  }

  Future<Vehicle> updateVehicle(int id, Vehicle vehicle) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/municipal/vehicles/$id'),
      headers: headers,
      body: jsonEncode(vehicle.toJson()),
    );

    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response.body);
      throw Exception(errorMsg);
    }
  }

  Future<void> deactivateVehicle(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/municipal/vehicles/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to deactivate vehicle: ${response.statusCode} - ${response.body}');
    }
  }

  // ================= Collection Jobs APIs =================

  Future<List<CollectionJob>> getAllJobs() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/jobs'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CollectionJob.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load collection jobs: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<CollectionJob>> getUnassignedJobs() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/jobs/unassigned'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CollectionJob.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load unassigned jobs: ${response.statusCode} - ${response.body}');
    }
  }

  // ================= Resource Assignment APIs =================

  Future<List<ResourceAssignment>> getAllAssignments() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/assignments'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ResourceAssignment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load assignments: ${response.statusCode} - ${response.body}');
    }
  }

  Future<ResourceAssignment> createAssignment(AssignmentRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/municipal/assignments'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return ResourceAssignment.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response.body);
      throw Exception(errorMsg);
    }
  }

  Future<ResourceAssignment> updateAssignment(int id, AssignmentRequest request) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/municipal/assignments/$id'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ResourceAssignment.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response.body);
      throw Exception(errorMsg);
    }
  }

  Future<void> cancelAssignment(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/municipal/assignments/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to cancel assignment: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> completeAssignment(int id) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/municipal/assignments/$id/complete'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to complete assignment: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> isEmployeeAssigned(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/employees/$id/assigned'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to check employee assignment status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> isVehicleAssigned(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/municipal/vehicles/$id/assigned'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to check vehicle assignment status: ${response.statusCode} - ${response.body}');
    }
  }

  // ================= Notifications APIs =================

  Future<List<NotificationModel>> getNotifications(String employeeId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/collector/notifications?employeeId=$employeeId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/collector/notifications/$id/read'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to mark notification as read: ${response.statusCode} - ${response.body}');
    }
  }

  // Help extract clean error message from backend response body if it is structured (e.g. spring error)
  String _extractErrorMessage(String body) {
    try {
      final map = jsonDecode(body);
      if (map is Map && map.containsKey('message')) {
        return map['message'] as String;
      }
    } catch (_) {}
    return body;
  }
}
