import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Interactive category / filter pill chip matching the reference design:
/// - When selected: Electric purple pill with white text & subtle purple shadow
/// - When unselected: Clean white pill with slate text and subtle border
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
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isSelected
        ? (activeColor ?? AppColors.primary)
        : (isDark ? AppColors.darkSurface : Colors.white);

    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B));
    final borderColor = isSelected
        ? (activeColor ?? AppColors.primary)
        : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (activeColor ?? AppColors.primary).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x060F172A),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
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
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
