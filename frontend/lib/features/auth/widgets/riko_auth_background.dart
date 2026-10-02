import 'package:flutter/material.dart';

/// Seamless full-screen lavender atmospheric background matching the Riko auth reference.
class RikoAuthBackground extends StatelessWidget {
  final Widget child;

  const RikoAuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF6F3FF),
            Color(0xFFFAF8FF),
            Color(0xFFFAF9FE),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Center-top soft radial atmospheric purple glow behind Riko hero
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            height: 480,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 500,
                  height: 480,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFDDD6FE).withValues(alpha: 0.50),
                        const Color(0xFFEDE9FE).withValues(alpha: 0.25),
                        const Color(0xFFF5F0FF).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.40, 0.70, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom soft cloud atmospheric glow (seamless, no border)
          Positioned(
            bottom: -60,
            left: 0,
            right: 0,
            height: 260,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 1.2,
                    colors: [
                      const Color(0xFFEDE9FE).withValues(alpha: 0.40),
                      const Color(0xFFF3EFFF).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.60, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Subtle 4-Point Sparkle Stars
          const Positioned(
            top: 75,
            left: 32,
            child: SparkleStar(size: 14, color: Color(0xFF8B5CF6), opacity: 0.60),
          ),
          const Positioned(
            top: 110,
            left: 95,
            child: SparkleStar(size: 10, color: Color(0xFFA78BFA), opacity: 0.45),
          ),
          const Positioned(
            top: 155,
            right: 28,
            child: SparkleStar(size: 16, color: Color(0xFF8B5CF6), opacity: 0.65),
          ),
          const Positioned(
            top: 195,
            right: 68,
            child: SparkleStar(size: 11, color: Color(0xFFA78BFA), opacity: 0.45),
          ),
          const Positioned(
            top: 360,
            left: 24,
            child: SparkleStar(size: 14, color: Color(0xFF8B5CF6), opacity: 0.45),
          ),
          const Positioned(
            top: 330,
            right: 38,
            child: SparkleStar(size: 13, color: Color(0xFFA78BFA), opacity: 0.45),
          ),
          const Positioned(
            bottom: 120,
            left: 32,
            child: SparkleStar(size: 13, color: Color(0xFF8B5CF6), opacity: 0.40),
          ),
          const Positioned(
            bottom: 140,
            right: 30,
            child: SparkleStar(size: 14, color: Color(0xFFA78BFA), opacity: 0.40),
          ),

          // Foreground Content inside SafeArea
          Positioned.fill(
            child: SafeArea(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Precise 4-point sparkle star matching the Riko art direction.
class SparkleStar extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const SparkleStar({
    super.key,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          size: Size(size, size),
          painter: _SparkleStarPainter(color: color),
        ),
      ),
    );
  }
}

class _SparkleStarPainter extends CustomPainter {
  final Color color;

  _SparkleStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final path = Path();
    // 4-point diamond star with curved concave edges
    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
