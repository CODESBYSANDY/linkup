import 'package:flutter/material.dart';
import 'riko_auth_background.dart';

/// Riko Brand Title & Subtitle block styled accurately to the reference.
class RikoBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompact;

  const RikoBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.isCompact = false,
  });

  static const Color navy = Color(0xFF111847);
  static const Color purple = Color(0xFF7C3AED);
  static const Color muted = Color(0xFF68709A);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Riko Logo with sparkle star
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6D28D9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                'Riko',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 36 : 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.0,
                  height: 1.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 3, top: isCompact ? 1 : 2),
              child: SparkleStar(
                size: isCompact ? 13 : 16,
                color: const Color(0xFFA855F7),
                opacity: 0.95,
              ),
            ),
          ],
        ),

        SizedBox(height: isCompact ? 5 : 8),

        // Screen Heading (e.g. "Welcome back")
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: navy,
            fontSize: isCompact ? 27 : 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),

        SizedBox(height: isCompact ? 5 : 7),

        // Subtitle (e.g. "Continue exploring opportunities\nwith Riko.")
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: muted,
            fontSize: isCompact ? 14 : 15.5,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
