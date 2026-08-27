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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF024B45)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}