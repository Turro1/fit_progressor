import 'package:flutter/material.dart';

class AppColors {
  // Theme: Suspension & Air Suspension Service (Orange, Dark Grey, White)
  // Colors inspired by automotive service: motor oil orange, industrial grey, metallic accents

  // Primary Colors
  static const Color primary = Color(
    0xFFFF8C00,
  ); // Vibrant orange - represents automotive service, oil, energy
  static const Color accent = Color(
    0xFFFFAB40,
  ); // Lighter orange for accents, highlights, and FABs

  // Secondary Colors
  static const Color secondary = Color(
    0xFF607D8B,
  ); // Blue Grey - industrial, technical look
  static const Color secondaryLight = Color(
    0xFF90A4AE,
  ); // Lighter blue grey for subtle accents

  // Backgrounds & Surfaces
  static const Color background = Color(
    0xFFF5F5F5,
  ); // Light grey background for the main app body
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // White for cards, modals, and sheets
  static const Color darkBackground = Color(
    0xFF1A1A1A,
  ); // Very dark grey for dark mode background
  static const Color darkSurface = Color(
    0xFF2C2C2C,
  ); // Dark grey for dark mode cards and surfaces

  // Text Colors
  static const Color textPrimary = Color(
    0xFF212121,
  ); // Almost black for primary text on light backgrounds
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Grey for secondary text on light backgrounds
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // White text on orange backgrounds
  static const Color darkTextPrimary = Color(
    0xFFFFFFFF,
  ); // White text for dark mode
  static const Color darkTextSecondary = Color(
    0xFFBDBDBD,
  ); // Light grey for secondary text in dark mode

  // Status & Feedback Colors
  static const Color error = Color(0xFFD32F2F); // Red for errors
  static const Color success = Color(
    0xFF4CAF50,
  ); // Green for success, provides contrast
  static const Color warning = Color(0xFFFFA000); // Amber for warnings
  static const Color info = Color(0xFF2196F3); // Blue for info

  // Special Colors for Auto Service
  static const Color metallic = Color(0xFF9E9E9E); // Grey for metallic parts
  static const Color oilGold = Color(0xFFFFB300); // Golden oil color

  // Borders & Shadows
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x33000000); // Subtle black shadow

  // Common
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Material 3 Container Colors
  static const Color primaryContainer = Color(
    0xFFFFE0B2,
  ); // Светло-оранжевый для контейнеров
  static const Color onPrimaryContainer = Color(
    0xFF3E2723,
  ); // Темный текст на primary контейнерах
  static const Color secondaryContainer = Color(
    0xFFB0BEC5,
  ); // Светло-серо-голубой
  static const Color onSecondaryContainer = Color(
    0xFF263238,
  ); // Темный текст на secondary контейнерах

  // Material 3 Error Container
  static const Color errorContainer = Color(0xFFFFDAD6); // Светло-красный
  static const Color onErrorContainer = Color(0xFF410002); // Тёмно-красный текст

  // Material 3 Tertiary Colors (золото/янтарь)
  static const Color tertiary = Color(
    0xFFFFB300,
  ); // Золото (oil gold как акцент)
  static const Color tertiaryContainer = Color(0xFFFFF8E1); // Светло-янтарный
  static const Color onTertiaryContainer = Color(0xFF4E342E);

  // Material 3 Surface Variants
  static const Color surfaceVariant = Color(
    0xFFF5F5F5,
  ); // Слегка отличается от surface
  static const Color surfaceContainer = Color(0xFFFAFAFA);
  static const Color surfaceContainerHigh = Color(0xFFEEEEEE);

  // Material 3 Outlines
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFEEEEEE);

  // ========== DARK THEME COLORS ==========

  // Dark Primary (оранжевый чуть приглушённый для тёмной темы)
  static const Color darkPrimary = Color(0xFFFFB74D);
  static const Color darkPrimaryContainer = Color(0xFF4A3000);
  static const Color darkOnPrimaryContainer = Color(0xFFFFDDB3);

  // Dark Secondary
  static const Color darkSecondary = Color(0xFF90A4AE);
  static const Color darkSecondaryContainer = Color(0xFF37474F);
  static const Color darkOnSecondaryContainer = Color(0xFFCFD8DC);

  // Dark Tertiary
  static const Color darkTertiary = Color(0xFFFFD54F);
  static const Color darkTertiaryContainer = Color(0xFF3E2723);
  static const Color darkOnTertiaryContainer = Color(0xFFFFE082);

  // Dark Error Container
  static const Color darkErrorContainer = Color(0xFF93000A); // Тёмно-красный
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6); // Светло-красный текст

  // Dark Surface variants
  static const Color darkSurfaceVariant = Color(0xFF3C3C3C);
  static const Color darkSurfaceContainer = Color(0xFF252525);
  static const Color darkSurfaceContainerHigh = Color(0xFF353535);
  static const Color darkSurfaceContainerHighest = Color(0xFF424242);

  // Dark Outlines
  static const Color darkOutline = Color(0xFF5C5C5C);
  static const Color darkOutlineVariant = Color(0xFF444444);

  // Dark Card border
  static const Color darkCardBorder = Color(0xFF424242);
}
