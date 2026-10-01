import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_shadows.dart';

/// Reusable dark card component with subtle borders, elevation, and optional glow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasGlow;
  final bool isElevated;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.hasGlow = false,
    this.isElevated = false,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? (isElevated ? AppColors.surfaceSecondary : AppColors.surface);
    final border = borderColor ?? (hasGlow ? AppColors.borderGlow : AppColors.border);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: border, width: 1.0),
        boxShadow: hasGlow ? AppShadows.purpleGlow : AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.cardRadius,
          child: content,
        ),
      );
    }

    return content;
  }
}
