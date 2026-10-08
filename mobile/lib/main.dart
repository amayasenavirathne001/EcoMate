import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'screens/dashboards/resident_dashboard.dart';
import 'screens/dashboards/collector_dashboard.dart';
import 'features/recycling/dashboard/recycling_dashboard.dart';
import 'screens/dashboards/council_dashboard.dart';

void main() {
  runApp(const EcoMateApp());
}

class EcoMateApp extends StatelessWidget {
  const EcoMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF024B45)),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thickness: MaterialStateProperty.all(0),
          thumbVisibility: MaterialStateProperty.all(false),
          trackVisibility: MaterialStateProperty.all(false),
        ),
      ),
      home: const InitializerScreen(),
    );
  }
}

class InitializerScreen extends StatefulWidget {
  const InitializerScreen({super.key});

  @override
  State<InitializerScreen> createState() => _InitializerScreenState();
}

class _InitializerScreenState extends State<InitializerScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final token = await _authService.getToken();
    final role = await _authService.getRole();

    if (token != null && role != null) {
      Widget dashboard;
      switch (role) {
        case 'RESIDENT':
          dashboard = const ResidentDashboard();
          break;
        case 'COLLECTOR':
          dashboard = const CollectorDashboard();
          break;
        case 'RECYCLING_OFFICER':
          dashboard = const RecyclingDashboard();
          break;
        case 'COUNCIL_ADMIN':
          dashboard = const CouncilDashboard();
          break;
        default:
          dashboard = const LoginScreen();
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => dashboard),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
