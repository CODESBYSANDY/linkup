import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';

/// Peeking Riko Avatar for header bars on Home, Explore, and Navigation screens:
/// Displays cute Riko illustration with tap interaction leading to Riko Assistant.
class RikoHeaderAvatar extends StatelessWidget {
  final double size;

  const RikoHeaderAvatar({
    super.key,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.assistant);
      },
      child: Tooltip(
        message: 'Chat with Riko Scout',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF3E8FF),
            border: Border.all(
              color: const Color(0xFFDDD6FE),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x108B5CF6),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/riko/riko.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.6),
            errorBuilder: (ctx, err, st) => const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
