import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Authentic LINKUP logo matching the reference design:
/// ✦ LINKUP
/// - "LINK" in deep navy (#0F172A)
/// - "U" in bright electric purple (#8B5CF6)
/// - "P" in bright gradient cyan/blue (#38BDF8 to #60A5FA)
/// - Optional 4-point sparkle star
class AppLogo extends StatelessWidget {
  final double fontSize;
  final bool showSparkle;
  final Color? navyColor;

  const AppLogo({
    super.key,
    this.fontSize = 28,
    this.showSparkle = true,
    this.navyColor,
  });

  @override
  Widget build(BuildContext context) {
    final darkNavy = navyColor ?? AppColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showSparkle) ...[
          Icon(
            Icons.auto_awesome,
            size: fontSize * 0.75,
            color: AppColors.softLavender,
          ),
          SizedBox(width: fontSize * 0.2),
        ],
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text: 'LINK',
                style: TextStyle(color: darkNavy),
              ),
              const TextSpan(
                text: 'U',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(
                text: 'P',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF60A5FA)],
                    ).createShader(Rect.fromLTWH(0, 0, fontSize, fontSize)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
