import 'package:flutter/material.dart';

/// Centralized color palette for the LINKUP application following the Riko design system.
/// 
/// Primary visual direction:
/// Futuristic dark navy / midnight violet (#08091F, #0B0D2A, #101333) with
/// electric purple (#8B5CF6, #A855F7), electric indigo (#6366F1), soft lavender (#A78BFA),
/// and crisp white / soft white typography (#F8FAFC, #E2E8F0).
abstract class AppColors {
  // Brand Primary & Accents (Purple / Violet)
  static const Color primary = Color(0xFF8B5CF6); // Electric Purple
  static const Color primaryBright = Color(0xFFA855F7); // Bright Purple
  static const Color primaryDark = Color(0xFF7C3AED); // Electric Violet
  static const Color primaryLight = Color(0xFFC4B5FD); // Light Violet
  static const Color softLavender = Color(0xFFA78BFA); // Soft Lavender Accent
  static const Color lavender = Color(0xFFA78BFA); // Soft Lavender Alias
  static const Color lightLavender = Color(0xFFDDD6FE); // Tinted Lavender

  // Brand Secondary & Highlights (Indigo / Electric Blue)
  static const Color secondary = Color(0xFF6366F1); // Indigo / Electric Blue
  static const Color electricBlue = Color(0xFF6366F1); // Electric Blue Alias
  static const Color secondaryDark = Color(0xFF4F46E5); // Deep Indigo
  static const Color secondaryLight = Color(0xFF818CF8); // Soft Blue-Violet
  static const Color cyanHighlight = Color(0xFF38BDF8); // Subtle Cyan / Tech Glow
  static const Color softTeal = Color(0x268B5CF6); // Soft Purple/Teal container replacement
  static const Color softBlue = Color(0x266366F1); // Soft Blue container

  // Dark Futuristic Background & Surface Hierarchy
  static const Color background = Color(0xFF08091F); // Deep Midnight Space Background
  static const Color backgroundAlt = Color(0xFF0B0D2A); // Midnight Ambient
  static const Color surface = Color(0xFF101333); // Card Surface
  static const Color surfaceSecondary = Color(0xFF141735); // Elevated Card Surface
  static const Color surfaceElevated = Color(0xFF181B42); // Modal / Action Surface
  static const Color surfaceHighlight = Color(0xFF1F2353); // Hover / Highlight Surface
  static const Color surfaceSubtle = Color(0xFF0D0F2E); // Inset Surface
  static const Color cardBackground = Color(0xFF101333); // Primary Card Background Alias
  static const Color cardBorder = Color(0x1FFFFFFF); // 12% White Border Alias

  // Backward compatibility aliases
  static const Color darkBackground = Color(0xFF08091F);
  static const Color darkSurface = Color(0xFF101333);
  static const Color darkSurfaceElevated = Color(0xFF181B42);
  static const Color darkSurfaceSubtle = Color(0xFF0D0F2E);

  // Typography / Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Crisp White
  static const Color textSecondary = Color(0xFFE2E8F0); // Soft White
  static const Color textMuted = Color(0xFFAAB2D5); // Muted Lavender-Slate
  static const Color textTertiary = Color(0xFF7E87B2); // Darker Muted Slate
  static const Color textInverse = Color(0xFF08091F); // Dark for on-light chips/buttons

  // Dark text aliases for compatibility
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFAAB2D5);
  static const Color darkTextTertiary = Color(0xFF7E87B2);

  // Borders & Dividers
  static const Color border = Color(0x1FFFFFFF); // 12% White Border
  static const Color borderSubtle = Color(0x12FFFFFF); // 7% White Border
  static const Color borderGlow = Color(0x668B5CF6); // Purple glowing border
  static const Color borderFocus = Color(0xFFA855F7); // Focused border
  static const Color darkBorder = Color(0x1FFFFFFF);
  static const Color darkBorderSubtle = Color(0x12FFFFFF);

  // Glows & Shadows
  static const Color glowPurple = Color(0x408B5CF6); // 25% Purple Glow
  static const Color glowPurpleStrong = Color(0x808B5CF6); // 50% Purple Glow
  static const Color glowBlue = Color(0x336366F1); // 20% Blue Glow
  static const Color glowCyan = Color(0x3338BDF8); // 20% Cyan Glow
  static const Color shadow = Color(0x66000000); // 40% Deep Black Shadow
  static const Color darkShadow = Color(0x80000000);
  static const Color overlay = Color(0x8008091F); // 50% Midnight Overlay

  // Status & Feedback
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color successSoft = Color(0x2622C55E);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningSoft = Color(0x26F59E0B);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorSoft = Color(0x26EF4444);
  static const Color info = Color(0xFF38BDF8); // Sky 400
  static const Color infoSoft = Color(0x2638BDF8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E1744), Color(0xFF101333)],
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
