import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Reusable Riko Recommendation Card matching Image 2 & Image 4:
/// - "Psst... I found a new hackathon you might like! 🎯"
/// - "Based on your interests in AI and Cybersecurity"
/// - "View Recommendation →" purple pill button
/// - 3D Riko mascot visual on the right
class RikoRecommendationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  const RikoRecommendationCard({
    super.key,
    this.title = 'Psst... I found a new\nhackathon you might like! 🎯',
    this.subtitle = 'Based on your interests in\nAI and Cybersecurity',
    this.buttonText = 'View Recommendation →',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2FF), // Soft tinted lavender per reference
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE9E0FF),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A8B5CF6),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Content on the left
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 120, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x338B5CF6),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Riko Mascot image positioned on right
          Positioned(
            right: 4,
            bottom: 0,
            top: 6,
            child: Image.asset(
              'assets/riko/riko.png',
              width: 115,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) => const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: AppColors.primaryBright,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
