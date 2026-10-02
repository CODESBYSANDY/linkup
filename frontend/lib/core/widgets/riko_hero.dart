import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import 'riko_expression.dart';

/// Hero character widget for Onboarding, Splash, and Featured Scout highlights.
class RikoHero extends StatelessWidget {
  final RikoExpression expression;
  final double size;
  final String? speechText;
  final String? badgeText;
  final bool animateGlow;

  const RikoHero({
    super.key,
    this.expression = RikoExpression.happy,
    this.size = 200,
    this.speechText,
    this.badgeText,
    this.animateGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (speechText != null) ...[
          _buildSpeechBubble(speechText!),
          const SizedBox(height: 16),
        ],
        Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Radial Glow Backdrop
            Container(
              width: size * 1.1,
              height: size * 1.1,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppShadows.rikoAura,
              ),
            ),

            // Subtle Orbit Rings
            Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBright.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
            ),

            // Character Container
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF26164A),
                    Color(0xFF13163E),
                    Color(0xFF0B0D2A),
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
                border: Border.all(
                  color: AppColors.primaryBright.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  expression.assetPath,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/riko/riko.png',
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => _buildHeroFallback(),
                    );
                  },
                ),
              ),
            ),

            // Decorative Sparkle Badges
            Positioned(
              top: 10,
              right: 18,
              child: _buildSparkle(16, AppColors.cyanHighlight),
            ),
            Positioned(
              bottom: 24,
              left: 12,
              child: _buildSparkle(12, AppColors.softLavender),
            ),

            if (badgeText != null)
              Positioned(
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.5)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 13, color: AppColors.softLavender),
                      const SizedBox(width: 6),
                      Text(
                        badgeText!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(
          color: AppColors.primaryBright.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: AppShadows.purpleGlow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryBright),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.rikoSpeech,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkle(double size, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.star_rounded,
        size: size,
        color: color,
      ),
    );
  }

  Widget _buildHeroFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_rounded,
            size: size * 0.44,
            color: AppColors.softLavender,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.primaryBright),
              const SizedBox(width: 4),
              Text(
                'RIKO SCOUT',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
