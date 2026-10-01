import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../core/widgets/riko_hero.dart';

/// Riko Onboarding / Get Started screen matching Reference Showcase.
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = const [
    {
      'title': 'Find. Apply.\nGrow. Together.',
      'subtitle': 'Riko helps you discover the best hackathons, internships, jobs and opportunities.',
      'expression': RikoExpression.waving,
      'badge': 'Your Opportunity Scout',
    },
    {
      'title': 'Personalized\nSmart Suggestions',
      'subtitle': 'Receive tailored hackathon teams, mentor sessions, and deadline reminders.',
      'expression': RikoExpression.usingTablet,
      'badge': 'AI Matched Feeds',
    },
    {
      'title': 'Connect with\nStudent Builders',
      'subtitle': 'Collaborate with collegiate developers, form teams, and share knowledge.',
      'expression': RikoExpression.celebrating,
      'badge': 'Student Tech Network',
    },
  ];

  void _onGetStarted() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
  }

  void _onSkip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        showAmbientGlow: true,
        showParticles: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Top Action Bar with Skip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.primaryBright, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'LINKUP',
                          style: AppTextStyles.labelSmall.copyWith(
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Center Riko Mascot Hero
                RikoHero(
                  expression: page['expression'] as RikoExpression,
                  size: 210,
                  badgeText: page['badge'] as String,
                ),

                const SizedBox(height: 36),

                // Title Headline
                Text(
                  page['title'] as String,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    page['subtitle'] as String,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                ),

                const Spacer(),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isActive = _currentPage == index;
                    return GestureDetector(
                      onTap: () => setState(() => _currentPage = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryBright : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActive ? AppColors.primaryLight : AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 28),

                // Primary CTA Button
                AppButton(
                  text: 'Get Started',
                  onPressed: _onGetStarted,
                  variant: AppButtonVariant.primary,
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
