import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  static const Color primaryGreen = Color(0xFF1F5520);
  static const Color backgroundColor = Colors.white;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Identify Your Waste',
      'description':
          'Scan any item to see if it is recyclable and which bin it belongs to.',

      // FIRST ONBOARDING IMAGE
      'image': 'assets/images/onboarding_1.png',
    },
    {
      'title': 'Find Nearby Bins',
      'description':
          'Locate the nearest smart recycling stations and drop-off points in your neighborhood.',

      // SECOND ONBOARDING IMAGE
      'image': 'assets/images/onboarding_2.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final page = _pages[index];

          return Stack(
            children: [
              // ====================================
              // WHITE TOP SECTION
              // ====================================
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                ),
              ),

              // ====================================
              // IMAGE IN CENTER OF WHITE AREA
              // ====================================
              Positioned(
                top: MediaQuery.of(context).size.height * 0.16,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    page['image']!,
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ====================================
              // GREEN WAVE SECTION
              // ====================================
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height:
                    MediaQuery.of(context).size.height * 0.53,
                child: ClipPath(
                  clipper: GreenWaveClipper(),
                  child: Container(
                    color: primaryGreen,
                    padding: const EdgeInsets.fromLTRB(
                      28,
                      80,
                      28,
                      24,
                    ),
                    child: Column(
                      children: [
                        const Spacer(),

                        // TITLE
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // DESCRIPTION
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 34),

                        // PAGE DOTS
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (dotIndex) {
                              final active =
                                  dotIndex == _currentPage;

                              return AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 250,
                                ),
                                margin:
                                    const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: active ? 8 : 5,
                                height: active ? 8 : 5,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                        ),

                        const Spacer(),

                        // NEXT / GET STARTED BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: index ==
                                  _pages.length - 1
                              ? ElevatedButton(
                                  onPressed: _nextPage,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white,
                                    foregroundColor:
                                        primaryGreen,
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        6,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                )
                              : OutlinedButton(
                                  onPressed: _nextPage,
                                  style:
                                      OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        24,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================================================
// THIS CREATES THE WAVE BETWEEN WHITE AND GREEN
// ==================================================

class GreenWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at left side
    path.moveTo(0, 40);

    // First small downward curve
    path.cubicTo(
      size.width * 0.15,
      65,
      size.width * 0.25,
      70,
      size.width * 0.38,
      48,
    );

    // Rise in the middle
    path.cubicTo(
      size.width * 0.55,
      15,
      size.width * 0.65,
      18,
      size.width * 0.78,
      42,
    );

    // Final downward curve
    path.cubicTo(
      size.width * 0.88,
      60,
      size.width * 0.94,
      70,
      size.width,
      55,
    );

    // Green area below
    path.lineTo(
      size.width,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}