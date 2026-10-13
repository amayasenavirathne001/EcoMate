import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'onboarding_screens.dart';
import 'dashboards/resident_dashboard.dart';
import 'dashboards/collector_dashboard.dart';
import '../features/recycling/dashboard/recycling_dashboard.dart';
import 'dashboards/council_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.8, curve: Curves.easeIn),
      ),
    );

    _runSplashAndNavigate();
  }

  Future<void> _runSplashAndNavigate() async {
    // 1. Play animation and concurrently check auth session
    final animFuture = _controller.forward();
    final authCheckFuture = _resolveTargetDestination();

    await animFuture;
    // Keep splash screen visible comfortably before navigating
    await Future.delayed(const Duration(milliseconds: 1200));
    final destination = await authCheckFuture;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<Widget> _resolveTargetDestination() async {
    try {
      final token = await _authService.getToken();
      final role = await _authService.getRole();

      if (token != null && role != null) {
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
            return const LoginScreen();
        }
      }
    } catch (_) {}

    // Not logged in: go to LoginScreen or OnboardingScreen
    return const LoginScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with Scale + Opacity
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0E8A38).withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/ecomate_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF0E8A38),
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title & Tagline with Slide + Fade
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Eco',
                              style: TextStyle(color: Color(0xFF071A26)),
                            ),
                            TextSpan(
                              text: 'Mate',
                              style: TextStyle(color: Color(0xFF0E8A38)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Together for a Cleaner Tomorrow',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}