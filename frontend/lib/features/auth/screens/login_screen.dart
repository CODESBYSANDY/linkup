import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/riko_speech_bubble.dart';

/// Screen 1: LINKUP Authentication & Welcome Screen
/// Faithfully reproduces Image 1 from the reference design:
/// - LINKUP logo with lavender sparkle
/// - 3D Riko mascot waving with goggles & floating speech bubble:
///   "Hey! Ready to find your next opportunity? ✨"
/// - Soft atmospheric lavender clouds & city silhouette background
/// - "Welcome to LINKUP" header with "Discover opportunities. Connect with your people. Grow together."
/// - "Continue with Google" vibrant royal purple/indigo gradient pill button with arrow
/// - "OR" divider
/// - "Continue with Phone" white pill button with purple border & arrow
/// - "Explore as Demo Student" subtle guest bypass
/// - Shield icon with Terms & Privacy Policy footer
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isGoogleLoading = false;
  bool _isGuestLoading = false;

  bool get _isProcessing => _isGoogleLoading || _isGuestLoading;

  // ============================================================
  // AUTHENTICATION HANDLERS
  // ============================================================

  Future<void> _handleGoogleSignIn() async {
    if (_isProcessing) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final success = await AppServices.auth.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        final user = AppServices.auth.currentUser;
        if (user != null && !user.isOnboarded) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.main);
        }
      }
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _handlePhoneLogin() {
    if (_isProcessing) return;
    Navigator.of(context).pushNamed(AppRoutes.phoneLogin);
  }

  Future<void> _handleGuestAccess() async {
    if (_isProcessing) return;

    setState(() {
      _isGuestLoading = true;
    });

    try {
      await AppServices.auth.loginAsGuest();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } finally {
      if (mounted) {
        setState(() {
          _isGuestLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FB), // Soft lavender tint per reference
      body: Stack(
        children: [
          // Background soft ambient clouds and sparkles
          Positioned.fill(
            child: _buildBackgroundArtwork(),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top LINKUP Logo
                      const SizedBox(height: 8),
                      const AppLogo(fontSize: 30, showSparkle: true),
                      const SizedBox(height: 16),

                      // Mascot & Speech Bubble Stage
                      _buildMascotStage(),

                      const SizedBox(height: 14),

                      // "Welcome to LINKUP"
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const AppLogo(fontSize: 36, showSparkle: false),

                      const SizedBox(height: 8),

                      // Tagline
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Discover opportunities. Connect with your people. Grow together.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Continue with Google Button
                      _buildGoogleButton(),

                      const SizedBox(height: 16),

                      // OR Divider
                      _buildOrDivider(),

                      const SizedBox(height: 16),

                      // Continue with Phone Button
                      _buildPhoneButton(),

                      const SizedBox(height: 16),

                      // Explore as Demo Student
                      TextButton(
                        onPressed: _isProcessing ? null : _handleGuestAccess,
                        child: _isGuestLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.school_outlined, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Explore as Demo Student',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: 12),

                      // Terms & Privacy Policy Footer
                      _buildTermsFooter(),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundArtwork() {
    return Stack(
      children: [
        // Subtle top radial glow
        Positioned(
          top: -100,
          left: -50,
          right: -50,
          height: 380,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0x33EDE9FE),
                  Color(0x10DDD6FE),
                  Colors.transparent,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Floating Paper Airplane per reference
        Positioned(
          top: 140,
          right: 32,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.send_rounded,
              color: const Color(0xFFC4B5FD).withValues(alpha: 0.6),
              size: 26,
            ),
          ),
        ),

        // Glowing 4-point sparkle star left
        Positioned(
          top: 220,
          left: 36,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
            size: 20,
          ),
        ),

        // Glowing 4-point sparkle star right
        Positioned(
          top: 280,
          right: 48,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMascotStage() {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ambient soft cloud ellipse below Riko
          Positioned(
            bottom: 0,
            child: Container(
              width: 260,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x188B5CF6),
                    blurRadius: 28,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          // 3D Riko Mascot illustration
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/riko/riko.png',
              height: 215,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) => const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 90,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Speech Bubble positioned to top-right of Riko per reference
          Positioned(
            top: 6,
            right: 12,
            child: const RikoSpeechBubble(
              text: 'Hey! Ready to find\nyour next opportunity? ✨',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x356366F1),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isProcessing ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                // White circular Google Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/riko/google_logo.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (ctx, err, st) => const Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Label
                Expanded(
                  child: Text(
                    _isGoogleLoading ? 'Signing you in...' : 'Continue with Google',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                // Arrow Right or Spinner
                if (_isGoogleLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFFCBD5E1), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFFCBD5E1), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildPhoneButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isProcessing ? null : _handlePhoneLogin,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                // Phone Icon in soft tinted circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.phone_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Label
                const Expanded(
                  child: Text(
                    'Continue with Phone',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                // Arrow Right
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsFooter() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 15,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text.rich(
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF64748B),
              ),
              children: [
                TextSpan(
                  text: 'Terms',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}