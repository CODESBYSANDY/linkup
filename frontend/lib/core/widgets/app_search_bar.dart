import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Reusable search bar widget matching Image 2:
/// - Crisp white rounded container with subtle border and shadow
/// - Purple search icon on left
/// - Purple sliders / filter icon on right
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search opportunities...',
    this.onChanged,
    this.onFilterTap,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x060F172A),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium.copyWith(color: textColor),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: hintColor,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: onFilterTap != null
              ? IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                  onPressed: onFilterTap,
                )
              : (controller != null && controller!.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        controller!.clear();
                        if (onChanged != null) onChanged!('');
                      },
                    )
                  : (onTap != null
                      ? const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary)
                      : null)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
