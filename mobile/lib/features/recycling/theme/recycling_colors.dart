import 'package:flutter/material.dart';

/// EcoMate Recycling Module Theme Colors
/// Aligned with EcoMate Resident and Municipal Dashboard Design (Fresh Eco Green).
class RecyclingColors {
  RecyclingColors._();

  // Primary Brand Colors (From ResidentDashboard & Municipal theme)
  static const Color primaryGreen    = Color(0xFF0E8A38); // Resident primary vibrant green
  static const Color mediumGreen     = Color(0xFF2E7D32); // Resident medium forest green
  static const Color darkGreen       = Color(0xFF1B5E20); // Deep forest green for dark surfaces/gradients
  static const Color deepForestGreen = Color(0xFF0E8A38); // Header & primary accents
  static const Color forestGreen     = Color(0xFF0E8A38); // Buttons, active icons, main accents
  static const Color softGreen       = Color(0xFFEDF8EC); // Soft minty card background tint
  static const Color sageGreen       = Color(0xFF10A85B); // Active badge & weight pill fill
  static const Color lightSage       = Color(0xFFDCEBD7); // Card borders & subtle accents
  static const Color offWhite        = Color(0xFFFAFCFA); // Clean page background (matches Resident)
  static const Color pageBg          = Color(0xFFFAFCFA); // Page background
  static const Color white           = Color(0xFFFFFFFF); // Pure white cards
  static const Color darkText        = Color(0xFF071A26); // Primary dark text
  static const Color primaryText     = Color(0xFF071A26); // Primary text
  static const Color secondaryText   = Color(0xFF64748B); // Slate subtitles & secondary text
  static const Color earthyBrown     = Color(0xFF64748B); // Secondary text alias
  static const Color oliveGreen      = Color(0xFF0E8A38); // Open/Live status color
  static const Color cardBorder      = Color(0xFFDCEBD7); // Light green border

  // Semantic mappings
  static const Color cardBg          = white;
  static const Color accent          = primaryGreen;
  static const Color success         = primaryGreen;
  static const Color error           = Color(0xFFE53935);
}
