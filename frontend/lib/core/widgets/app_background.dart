import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Atmospheric dark background container with subtle purple & blue radial ambient glows.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showAmbientGlow;
  final bool showParticles;

  const AppBackground({
    super.key,
    required this.child,
    this.showAmbientGlow = true,
    bool? showGlows,
    this.showParticles = false,
  }) : showAmbientGlowState = showGlows ?? showAmbientGlow;

  final bool showAmbientGlowState;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showAmbientGlowState) ...[
            // Purple Top Glow
            Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryDark.withValues(alpha: 0.28),
                      AppColors.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Blue / Violet Bottom Right Glow
            Positioned(
              bottom: -100,
              right: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondaryDark.withValues(alpha: 0.22),
                      AppColors.secondary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
          if (showParticles) ...[
            // Subtle decorative stars
            Positioned(
              top: 80,
              right: 40,
              child: _buildStar(4, AppColors.softLavender.withValues(alpha: 0.6)),
            ),
            Positioned(
              top: 220,
              left: 30,
              child: _buildStar(3, AppColors.cyanHighlight.withValues(alpha: 0.5)),
            ),
            Positioned(
              bottom: 160,
              right: 50,
              child: _buildStar(5, AppColors.softLavender.withValues(alpha: 0.7)),
            ),
          ],
          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _buildStar(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
