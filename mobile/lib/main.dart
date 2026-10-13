import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

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
      home: const SplashScreen(),
    );
  }
}
