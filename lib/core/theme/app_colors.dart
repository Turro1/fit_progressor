import 'package:flutter/material.dart';

class AppColors {
  // Theme: Car Service (Red, Black, White)

  // Primary Colors
  static const Color primary = Color(0xFFD32F2F); // A strong, classic red for primary actions, headers.
  static const Color accent = Color(0xFFFF5252); // A brighter red for accents, highlights, and FABs.

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF5F5F5); // Light grey background for the main app body.
  static const Color surface = Color(0xFFFFFFFF); // White for cards, modals, and sheets.
  static const Color darkBackground = Color(0xFF121212); // True black for dark mode background.
  static const Color darkSurface = Color(0xFF1E1E1E); // Off-black for dark mode cards and surfaces.

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Almost black for primary text on light backgrounds.
  static const Color textSecondary = Color(0xFF757575); // Grey for secondary text on light backgrounds.
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on red backgrounds.
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // White text for dark mode.
  static const Color darkTextSecondary = Color(0xFFBDBDBD); // Light grey for secondary text in dark mode.

  // Status & Feedback Colors
  static const Color error = Color(0xFFD32F2F); // Using the primary red for errors.
  static const Color success = Color(0xFF4CAF50); // A standard green for success, provides contrast.
  static const Color warning = Color(0xFFFFA000); // A standard amber for warnings.
  static const Color info = Color(0xFF1976D2); // A standard blue for info.

  // Borders & Shadows
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x33000000); // Subtle black shadow.
  
  // Common
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
}