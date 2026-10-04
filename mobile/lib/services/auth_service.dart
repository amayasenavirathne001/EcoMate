import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthService {
  static final ValueNotifier<int> profileUpdateNotifier = ValueNotifier(0);

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      await _storage.write(
        key: 'token',
        value: data['token'] as String,
      );

      await _storage.write(
        key: 'role',
        value: data['role'] as String,
      );

      await _storage.write(
        key: 'name',
        value: data['name'] as String,
      );

      await _storage.write(
        key: 'email',
        value: data['email'] as String,
      );

      return data;
    }

    if (response.statusCode == 401) {
      throw Exception('Invalid email or password');
    }

    throw Exception('Login failed');
  }

  Future<String?> getToken() {
    return _storage.read(key: 'token');
  }

  Future<String?> getRole() {
    return _storage.read(key: 'role');
  }

  Future<String?> getEmail() {
    return _storage.read(key: 'email');
  }

  Future<String?> getName() {
    return _storage.read(key: 'name');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // NEW METHOD
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        data['profilePic'] = data['profilePictureData'];
        return data;
      }

      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        await logout();
        return null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profilePicUrl,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please log in before updating your profile.');
    }
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('Could not load your current profile. Please try again.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name ?? currentUser['name'] ?? '',
        'phoneNumber': phoneNumber ?? currentUser['phoneNumber'] ?? '',
        'address': address ?? currentUser['address'] ?? '',
        'profilePictureData':
            profilePicUrl ?? currentUser['profilePictureData'] ?? '',
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Could not update your profile (${response.statusCode}).',
      );
    }

    final updated = jsonDecode(response.body) as Map<String, dynamic>;
    await _storage.write(key: 'name', value: updated['name']?.toString() ?? '');
    await _storage.write(
      key: 'email',
      value: updated['email']?.toString() ?? '',
    );
    profileUpdateNotifier.value++;
  }

  Future<void> updateSecurity({required String email, required String currentPassword, required String newPassword}) async {
    // Dummy implementation for prototype
    await _storage.write(key: 'email', value: email);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/register'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }

  throw Exception(
    'Registration failed: ${response.statusCode} - ${response.body}',
  );
 }
}
