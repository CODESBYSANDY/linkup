import 'package:flutter/material.dart';

/// Centralized color palette for the LINKUP application following the Riko design system.
/// 
/// Primary visual direction:
/// Futuristic dark navy / midnight violet (#08091F, #0B0D2A, #101333) with
/// electric purple (#8B5CF6, #A855F7), electric indigo (#6366F1), soft lavender (#A78BFA),
/// and crisp white / soft white typography (#F8FAFC, #E2E8F0).
abstract class AppColors {
  // Brand Primary & Accents (Purple / Violet)
  // ============================================================
  // BRAND ACCENTS (Purple / Violet / Indigo)
  // ============================================================
  static const Color primary = Color(0xFF8B5CF6); // Electric Purple / Bright Violet
  static const Color primaryBright = Color(0xFFA855F7); // Vivid Purple
  static const Color primaryDark = Color(0xFF7C3AED); // Deep Royal Purple
  static const Color primaryLight = Color(0xFFC4B5FD); // Light Violet
  static const Color softLavender = Color(0xFFA78BFA); // Soft Lavender
  static const Color lavender = Color(0xFFA78BFA); // Alias
  static const Color lightLavender = Color(0xFFEDE9FE); // Pastel Tinted Lavender (100)
  static const Color ultraLightLavender = Color(0xFFF5F3FF); // Ultra Soft Lavender (50)

  // Secondary Accents & Tech Glows
  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color electricBlue = Color(0xFF6366F1);
  static const Color secondaryDark = Color(0xFF4F46E5); // Deep Indigo
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color cyanHighlight = Color(0xFF38BDF8); // Sky / Cyan Accent
  static const Color softTeal = Color(0xFF0D9488); // Teal Accent

  // ============================================================
  // BACKGROUNDS & SURFACES (Soft Lavender & Crisp White)
  // ============================================================
  // Primary application background: very soft lavender / off-white per reference
  static const Color background = Color(0xFFF6F5FB); 
  static const Color backgroundAlt = Color(0xFFF0EDF9);
  static const Color surface = Color(0xFFFFFFFF); // Pure White Cards
  static const Color surfaceSecondary = Color(0xFFFAFAFE); // Inset Surface
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Elevated Cards
  static const Color surfaceHighlight = Color(0xFFF3E8FF); // Purple Highlight Tint
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle Slate Border

  // Dark Navy banner for featured cards (per reference "Featured for you")
  static const Color darkFeaturedCard = Color(0xFF101333);
  static const Color darkBackground = Color(0xFF101333);
  static const Color darkSurface = Color(0xFF181B42);
  static const Color darkSurfaceElevated = Color(0xFF1F2353);
  static const Color darkSurfaceSubtle = Color(0xFF0D0F2E);
  static const Color darkSurfaceSecondary = Color(0xFF1E224F);

  // ============================================================
  // TYPOGRAPHY (Deep Navy & Slate Neutrals)
  // ============================================================
  static const Color textPrimary = Color(0xFF0F172A); // Confident Deep Navy
  static const Color textSecondary = Color(0xFF334155); // Dark Slate Body
  static const Color textMuted = Color(0xFF64748B); // Slate Muted
  static const Color textTertiary = Color(0xFF94A3B8); // Light Slate
  static const Color textInverse = Color(0xFFFFFFFF); // White on colored backgrounds

  // Dark Theme Typography (High-contrast Slate on dark surfaces)
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50 (Crisp Light Text)
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300 (Body Text)
  static const Color darkTextMuted = Color(0xFF94A3B8); // Slate 400 (Muted Text)
  static const Color darkTextTertiary = Color(0xFF64748B); // Slate 500

  // ============================================================
  // BORDERS & DIVIDERS
  // ============================================================
  static const Color border = Color(0xFFE2E8F0); // 1px Slate Border
  static const Color borderSubtle = Color(0xFFF1F5F9); // Light Divider
  static const Color borderGlow = Color(0x338B5CF6); // Soft Purple Glow Border
  static const Color borderFocus = Color(0xFF8B5CF6); // Focused Border
  static const Color darkBorder = Color(0xFF282C62); // Subtle Dark Navy Border
  static const Color darkBorderSubtle = Color(0xFF1E224F); // Dark Divider

  // ============================================================
  // CATEGORY SHORTCUT ACCENTS (per reference Image 2)
  // ============================================================
  static const Color catHackathonsBg = Color(0xFFEDE9FE); // Purple 100
  static const Color catHackathonsIcon = Color(0xFF7C3AED); // Purple 700

  static const Color catInternshipsBg = Color(0xFFDCFCE7); // Green 100
  static const Color catInternshipsIcon = Color(0xFF16A34A); // Green 600

  static const Color catJobsBg = Color(0xFFFEE2E2); // Red 100
  static const Color catJobsIcon = Color(0xFFDC2626); // Red 600

  static const Color catEventsBg = Color(0xFFDBEAFE); // Blue 100
  static const Color catEventsIcon = Color(0xFF2563EB); // Blue 600

  // ============================================================
  // STATUS & FEEDBACK
  // ============================================================
  static const Color deadlineOrange = Color(0xFFEA580C); // Orange for "Deadline in X days"
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successSoft = Color(0x2616A34A);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningSoft = Color(0x26F59E0B);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorSoft = Color(0x26EF4444);
  static const Color info = Color(0xFF38BDF8); // Sky 400
  static const Color infoSoft = Color(0x2638BDF8);

  // ============================================================
  // SHADOWS & GLOWS
  // ============================================================
  static const Color shadow = Color(0x0C0F172A); // Very soft clean shadow
  static const Color shadowMedium = Color(0x140F172A);
  static const Color darkShadow = Color(0x20000000);
  static const Color glowPurple = Color(0x338B5CF6);
  static const Color glowPurpleStrong = Color(0x668B5CF6);
  static const Color glowBlue = Color(0x266366F1);
  static const Color glowCyan = Color(0x2638BDF8);
  static const Color overlay = Color(0x50000000);

  // ============================================================
  // GRADIENTS
  // ============================================================
  // Continue with Google & Apply button gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient recommendationGradient = LinearGradient(
    colors: [Color(0xFFF5F0FF), Color(0xFFEDE5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rikoGlowGradient = LinearGradient(
    colors: [Color(0x33A855F7), Color(0x106366F1), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color transparent = Colors.transparent;
}
