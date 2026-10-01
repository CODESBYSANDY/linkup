import 'package:flutter/material.dart';

/// Centralized color palette for the application.
/// 
/// Primary visual direction:
/// Light Teal / Turquoise + Blue + White / Deep Navy.
/// 
/// Note: All colors are accessed through this class to ensure the branding
/// can be easily customized without modifying individual widgets.
abstract class AppColors {
  // Primary & Accent Brand Colors
  static const Color primary = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF0D9488); // Teal 600
  static const Color primaryLight = Color(0xFF2DD4BF); // Teal 400
  static const Color softTeal = Color(0xFFECFDF5); // Teal 50

  static const Color secondary = Color(0xFF2563EB); // Blue 600
  static const Color secondaryDark = Color(0xFF1D4ED8); // Blue 700
  static const Color secondaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color softBlue = Color(0xFFEFF6FF); // Blue 50

  // Light Mode Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100

  // Dark Mode Background & Surface
  static const Color darkBackground = Color(0xFF0B0F17); // Deep Midnight
  static const Color darkSurface = Color(0xFF131C2E); // Deep Slate Navy
  static const Color darkSurfaceElevated = Color(0xFF1A263C);
  static const Color darkSurfaceSubtle = Color(0xFF1E293B);

  // Typography / Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // Dark Mode Text Colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Borders, Dividers & Outlines
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color borderFocus = Color(0xFF14B8A6); // Teal 500
  static const Color darkBorder = Color(0xFF263346); // Dark Slate border
  static const Color darkBorderSubtle = Color(0xFF1E293B);

  // Feedback & Status
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successSoft = Color(0xFFDCFCE7); // Green 100
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningSoft = Color(0xFFFEF3C7); // Amber 100
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorSoft = Color(0xFFFEE2E2); // Red 100
  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoSoft = Color(0xFFE0F2FE); // Sky 100

  // Misc & Overlays
  static const Color shadow = Color(0x0A0F172A); // Very soft deep navy shadow
  static const Color darkShadow = Color(0x33000000);
  static const Color overlay = Color(0x660F172A);
  static const Color transparent = Colors.transparent;
}
