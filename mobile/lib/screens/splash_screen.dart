import 'package:flutter/material.dart';
import 'onboarding_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _eController;
  late AnimationController _wordController;

  late Animation<double> _eScale;
  late Animation<double> _eOpacity;

  late Animation<Offset> _wordSlide;
  late Animation<double> _wordOpacity;

  @override
  void initState() {
    super.initState();

    _eController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _eScale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _eController,
        curve: Curves.easeOutBack,
      ),
    );

    _eOpacity = CurvedAnimation(
      parent: _eController,
      curve: Curves.easeIn,
    );

    _wordController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // coMate enters FROM THE RIGHT
    _wordSlide = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _wordController,
        curve: Curves.easeOutCubic,
      ),
    );

    _wordOpacity = CurvedAnimation(
      parent: _wordController,
      curve: Curves.easeIn,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // First show E
    await _eController.forward();

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    // Then coMate comes from right
    await _wordController.forward();

    // Keep EcoMate visible
    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OnboardingScreen()
      ),
    );
  }

  @override
  void dispose() {
    _eController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Green from your reference image
      backgroundColor: const Color(0xFF176524),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First E
            ScaleTransition(
              scale: _eScale,
              child: FadeTransition(
                opacity: _eOpacity,
                child: const Text(
                  'e',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // coMate enters from right
            ClipRect(
              child: SlideTransition(
                position: _wordSlide,
                child: FadeTransition(
                  opacity: _wordOpacity,
                  child: const Text(
                    'coMate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}