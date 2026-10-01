import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_text_styles.dart';

/// Interactive filter / category chip matching the Riko design language.
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final IconData? icon;
  final Color? activeColor;
  final EdgeInsetsGeometry padding;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
    this.activeColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? (activeColor ?? AppColors.primary)
        : AppColors.surfaceSecondary;

    final textColor = isSelected ? AppColors.textPrimary : AppColors.textMuted;
    final borderColor = isSelected
        ? (activeColor ?? AppColors.primaryBright).withValues(alpha: 0.8)
        : AppColors.borderSubtle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: AppRadii.chipRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.chipRadius,
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (activeColor ?? AppColors.primary).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: textColor,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
