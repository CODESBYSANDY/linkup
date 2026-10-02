import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Speech bubble for Riko mascot with subtle pointer tail matching Image 1:
/// "Hey! Ready to find your next opportunity? ✨"
class RikoSpeechBubble extends StatelessWidget {
  final String text;

  const RikoSpeechBubble({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }
}
