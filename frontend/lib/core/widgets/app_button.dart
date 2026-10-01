import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

/// Reusable button widget matching the Riko visual system.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent;

    if (isLoading) {
      buttonContent = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      buttonContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: variant == AppButtonVariant.ghost
                  ? AppColors.softLavender
                  : AppColors.textPrimary,
            ),
          ),
        ],
      );
    }

    BoxDecoration decoration;
    switch (variant) {
      case AppButtonVariant.primary:
        decoration = BoxDecoration(
          borderRadius: AppRadii.buttonRadius,
          gradient: onPressed == null
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: onPressed == null ? AppColors.surfaceElevated : null,
          boxShadow: onPressed == null ? null : AppShadows.buttonGlow,
        );
        break;
      case AppButtonVariant.secondary:
        decoration = BoxDecoration(
          borderRadius: AppRadii.buttonRadius,
          color: AppColors.surfaceElevated,
          border: Border.all(color: AppColors.border),
        );
        break;
      case AppButtonVariant.outline:
        decoration = BoxDecoration(
          borderRadius: AppRadii.buttonRadius,
          border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.6), width: 1.5),
        );
        break;
      case AppButtonVariant.ghost:
        decoration = BoxDecoration(
          borderRadius: AppRadii.buttonRadius,
          color: Colors.transparent,
        );
        break;
    }

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadii.buttonRadius,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: decoration,
          alignment: Alignment.center,
          child: buttonContent,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
