import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_expression.dart';

/// Splash screen introducing LINKUP with Riko — Your Opportunity Scout.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    if (AppServices.auth.isLoggedIn) {
      final user = AppServices.auth.currentUser;
      if (user != null && !user.isOnboarded) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        showAmbientGlow: true,
        showParticles: true,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Glowing 4-point Riko Star Emblem
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBright.withValues(alpha: 0.4),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: AppColors.primaryBright,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Riko Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Riko',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: AppColors.softLavender,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Your Opportunity Scout.',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Subtle glowing progress indicator
                    Container(
                      width: 140,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBright),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom Riko Character Peek
                    const RikoAvatar(
                      expression: RikoExpression.happy,
                      size: 90,
                      showGlow: true,
                    ),

                    const SizedBox(height: 16),

                    // LinkUp Branding
                    Text(
                      'LINKUP',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 3.0,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
