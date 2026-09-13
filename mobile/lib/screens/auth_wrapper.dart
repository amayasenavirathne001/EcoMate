import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboards/resident_dashboard.dart';
import 'dashboards/collector_dashboard.dart';
import '../features/recycling/dashboard/recycling_dashboard.dart';
import 'dashboards/council_dashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return snapshot.data ?? const LoginScreen();
      },
    );
  }

 Future<Widget> _checkSession() async {
  final user = await _authService.getCurrentUser();

  if (user == null) {
    return const LoginScreen();
  }

  final role = user['role'] as String?;

  switch (role) {
    case 'RESIDENT':
      return const ResidentDashboard();

    case 'COLLECTOR':
      return const CollectorDashboard();

    case 'RECYCLING_OFFICER':
      return const RecyclingDashboard();

    case 'COUNCIL_ADMIN':
      return const CouncilDashboard();

    default:
      await _authService.logout();
      return const LoginScreen();
  }
 }
}