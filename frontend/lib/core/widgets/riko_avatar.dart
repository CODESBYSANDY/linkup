import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_shadows.dart';
import 'riko_expression.dart';

/// Interactive & responsive Riko Avatar widget.
/// 
/// Accepts a [RikoExpression], custom size, and optional glowing aura.
/// When asset images are provided in `assets/riko/`, it seamlessly renders them,
/// otherwise cleanly falls back to the stylized Riko Scout insignia.
class RikoAvatar extends StatelessWidget {
  final RikoExpression expression;
  final double size;
  final bool showGlow;
  final bool showBadge;
  final VoidCallback? onTap;

  const RikoAvatar({
    super.key,
    this.expression = RikoExpression.happy,
    this.size = 44,
    this.showGlow = false,
    this.showBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1B54), Color(0xFF13173D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primaryBright.withValues(alpha: 0.6),
          width: size > 60 ? 2.5 : 1.5,
        ),
        boxShadow: showGlow ? AppShadows.purpleGlow : null,
      ),
      child: ClipOval(
        child: Image.asset(
          expression.assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/riko/riko.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.6),
              errorBuilder: (ctx, err, st) => _buildVectorFallback(size),
            );
          },
        ),
      ),
    );

    if (showBadge) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.primaryBright,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildVectorFallback(double s) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle Riko Goggles & Sparkle Motif
          Icon(
            Icons.smart_toy_rounded,
            size: s * 0.55,
            color: AppColors.softLavender,
          ),
          Positioned(
            top: s * 0.16,
            right: s * 0.16,
            child: Icon(
              Icons.star_rounded,
              size: s * 0.24,
              color: AppColors.cyanHighlight,
            ),
          ),
        ],
      ),
    );
  }
}
