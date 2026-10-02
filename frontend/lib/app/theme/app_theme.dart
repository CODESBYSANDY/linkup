import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radii.dart';

/// Centralized Material 3 Theme configuration for LINKUP (Riko Design System).
class AppTheme {
  AppTheme._();

  /// Light Theme (The primary visual specification shown in reference screenshots)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.lightLavender,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.surfaceHighlight,
        onSecondaryContainer: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorSoft,
        onErrorContainer: AppColors.error,
        outline: AppColors.border,
        outlineVariant: AppColors.borderSubtle,
        shadow: AppColors.shadow,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceSubtle,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Input / TextField Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceSubtle,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.chipRadius,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        showCheckmark: false,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  /// Dark Theme (Intentional futuristic dark navy/violet design matching LINKUP identity)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.darkSurfaceElevated,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.darkSurfaceSubtle,
        onSecondaryContainer: AppColors.softLavender,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorSoft,
        onErrorContainer: AppColors.error,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorderSubtle,
        shadow: Colors.black,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextSecondary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextMuted),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.darkTextMuted),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.darkTextSecondary,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.darkSurfaceElevated,
          disabledForegroundColor: AppColors.darkTextMuted,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input / TextField Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextMuted),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        prefixIconColor: AppColors.primaryLight,
        suffixIconColor: AppColors.primaryLight,
        border: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.darkSurfaceSubtle,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextPrimary),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.chipRadius,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        showCheckmark: false,
      ),

      // SnackBar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextMuted,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
