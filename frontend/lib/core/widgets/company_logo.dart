import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Renders authentic company logos for opportunities matching the reference design:
/// - AWS (Black badge with 'aws' and curved smile)
/// - Google (White badge with official multicolor G or crisp letter)
/// - Flipkart (Yellow badge with iconic 'f' bag)
/// - ISRO (White badge with saffron rocket emblem)
/// - TCS (Teal/dark green monogram)
/// - Meta (White badge with blue infinity)
/// - Microsoft (White badge with 4 colored windows)
class CompanyLogo extends StatelessWidget {
  final String organization;
  final double size;
  final double borderRadius;

  const CompanyLogo({
    super.key,
    required this.organization,
    this.size = 44,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final orgLower = organization.toLowerCase();

    if (orgLower.contains('aws') || orgLower.contains('amazon')) {
      return _buildAwsLogo();
    } else if (orgLower.contains('google')) {
      return _buildGoogleLogo();
    } else if (orgLower.contains('flipkart')) {
      return _buildFlipkartLogo();
    } else if (orgLower.contains('isro')) {
      return _buildIsroLogo();
    } else if (orgLower.contains('meta') || orgLower.contains('facebook')) {
      return _buildMetaLogo();
    } else if (orgLower.contains('microsoft')) {
      return _buildMicrosoftLogo();
    } else if (orgLower.contains('tcs') || orgLower.contains('tata')) {
      return _buildTcsLogo();
    }

    return _buildGenericLogo();
  }

  Widget _buildAwsLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF131921), // AWS Black
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'aws',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 18,
              height: 2.5,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9900), // AWS Smile Orange
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Multicolored G simulation
            Text(
              'G',
              style: TextStyle(
                fontSize: size * 0.58,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [
                      Color(0xFF4285F4), // Blue
                      Color(0xFFEA4335), // Red
                      Color(0xFFFBBC05), // Yellow
                      Color(0xFF34A853), // Green
                    ],
                    stops: [0.0, 0.35, 0.7, 1.0],
                  ).createShader(Rect.fromLTWH(0, 0, size, size)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipkartLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE11B), // Flipkart Yellow
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.shopping_bag_rounded,
              color: const Color(0xFF2874F0), // Flipkart Blue
              size: size * 0.62,
            ),
            Positioned(
              top: size * 0.28,
              child: const Text(
                'f',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIsroLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              color: const Color(0xFFFF6D00), // ISRO Saffron
              size: size * 0.38,
            ),
            const SizedBox(height: 1),
            const Text(
              'इसरो isro',
              style: TextStyle(
                color: Color(0xFF0D9488),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.all_inclusive_rounded,
          color: const Color(0xFF0081FB), // Meta Blue
          size: size * 0.65,
        ),
      ),
    );
  }

  Widget _buildMicrosoftLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.46,
          height: size * 0.46,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: size * 0.2, height: size * 0.2, color: const Color(0xFFF25022)), // Red
                  const SizedBox(width: 2),
                  Container(width: size * 0.2, height: size * 0.2, color: const Color(0xFF7FBA00)), // Green
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: size * 0.2, height: size * 0.2, color: const Color(0xFF00A4EF)), // Blue
                  const SizedBox(width: 2),
                  Container(width: size * 0.2, height: size * 0.2, color: const Color(0xFFFFB900)), // Yellow
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTcsLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E), // TCS Green/Teal
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: Text(
          'TCS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGenericLogo() {
    final initials = organization.isNotEmpty
        ? (organization.length >= 2 ? organization.substring(0, 2).toUpperCase() : organization.toUpperCase())
        : 'OP';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lightLavender,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
