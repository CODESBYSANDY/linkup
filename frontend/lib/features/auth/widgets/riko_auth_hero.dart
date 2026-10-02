import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Large prominent Riko Hero illustration with 3D mascot artwork and floating opportunity badges.
class RikoAuthHero extends StatelessWidget {
  final double height;

  const RikoAuthHero({
    super.key,
    this.height = 240,
  });

  static const String rikoAsset = 'assets/riko/riko.png';
  static const String rikoLoginAsset = 'assets/riko/riko_login.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final centerX = w / 2;

          // Large prominent mascot
          final mascotHeight = h * 0.98;
          final badgeSize = h < 190 ? 38.0 : 46.0;
          final badgeIconSize = h < 190 ? 20.0 : 24.0;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Radial soft purple background glow halo behind Riko
              Positioned(
                top: -10,
                child: Container(
                  width: h * 1.35,
                  height: h * 1.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFDDD6FE).withValues(alpha: 0.65),
                        const Color(0xFFEDE9FE).withValues(alpha: 0.30),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.50, 1.0],
                    ),
                  ),
                ),
              ),

              // Large 3D Riko Character Centerpiece
              Positioned(
                top: 0,
                bottom: 0,
                child: Hero(
                  tag: 'riko_auth_character',
                  child: Image.asset(
                    rikoAsset,
                    height: mascotHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        rikoLoginAsset,
                        height: mascotHeight,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error2, stackTrace2) {
                          return Image.asset(
                            'assets/images/riko.png',
                            height: mascotHeight,
                            fit: BoxFit.contain,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // 1. Top Left Badge: Graduation Cap (Purple/Lavender)
              Positioned(
                left: math.max(10, centerX - 155),
                top: h * 0.08,
                child: FloatingOpportunityBadge(
                  icon: Icons.school_rounded,
                  colors: const [Color(0xFFB197FC), Color(0xFF7C3AED)],
                  shadowColor: const Color(0x447C3AED),
                  angle: -0.14,
                  size: badgeSize,
                  iconSize: badgeIconSize,
                ),
              ),

              // 2. Mid Left Badge: Briefcase (Coral / Pink)
              Positioned(
                left: math.max(2, centerX - 180),
                top: h * 0.40,
                child: FloatingOpportunityBadge(
                  icon: Icons.business_center_rounded,
                  colors: const [Color(0xFFF472B6), Color(0xFFEC4899)],
                  shadowColor: const Color(0x44EC4899),
                  angle: -0.18,
                  size: badgeSize + 2,
                  iconSize: badgeIconSize + 1,
                ),
              ),

              // 3. Bottom Left Badge: Community (Indigo / Blue)
              Positioned(
                left: math.max(18, centerX - 148),
                top: h * 0.68,
                child: FloatingOpportunityBadge(
                  icon: Icons.groups_rounded,
                  colors: const [Color(0xFF60A5FA), Color(0xFF6366F1)],
                  shadowColor: const Color(0x446366F1),
                  angle: -0.10,
                  size: badgeSize - 2,
                  iconSize: badgeIconSize - 2,
                ),
              ),

              // 4. Top Right Badge: Trophy (Violet / Purple)
              Positioned(
                right: math.max(12, centerX - 155),
                top: h * 0.06,
                child: FloatingOpportunityBadge(
                  icon: Icons.emoji_events_rounded,
                  colors: const [Color(0xFFC084FC), Color(0xFF8B5CF6)],
                  shadowColor: const Color(0x448B5CF6),
                  angle: 0.16,
                  size: badgeSize + 2,
                  iconSize: badgeIconSize + 1,
                ),
              ),

              // 5. Mid Right Badge: Calendar (Cyan / Blue)
              Positioned(
                right: math.max(6, centerX - 175),
                top: h * 0.42,
                child: FloatingOpportunityBadge(
                  icon: Icons.calendar_month_rounded,
                  colors: const [Color(0xFF38BDF8), Color(0xFF3B82F6)],
                  shadowColor: const Color(0x443B82F6),
                  angle: 0.12,
                  size: badgeSize,
                  iconSize: badgeIconSize,
                ),
              ),

              // Excitement / speed accent marks on right of Riko
              Positioned(
                right: math.max(centerX - 90, 65),
                top: h * 0.28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 15,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Floating translucent glossy badge with vibrant gradient and soft glow.
class FloatingOpportunityBadge extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final Color shadowColor;
  final double angle;
  final double size;
  final double iconSize;

  const FloatingOpportunityBadge({
    super.key,
    required this.icon,
    required this.colors,
    required this.shadowColor,
    required this.angle,
    this.size = 46,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.36),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.50),
              blurRadius: 3,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
