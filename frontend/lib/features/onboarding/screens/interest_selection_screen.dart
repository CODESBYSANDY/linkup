import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../data/models/user_profile.dart';

/// Step 2 of onboarding: Choose student technical interests and domains.
class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final List<String> _availableInterests = const [
    '🛡️ Cybersecurity',
    '🤖 AI / ML',
    '💻 Software Development',
    '🌐 Web Development',
    '☁️ Cloud & DevOps',
    '🔌 Networking',
    '📊 Data Science',
    '⚡ IoT & Embedded',
    '🔬 Research & Papers',
    '🏆 Hackathons',
    '🧠 Competitive Programming',
    '🏗️ System Design',
    '📱 Mobile Development',
    '⛓️ Blockchain & Web3',
  ];

  late final Set<String> _selectedInterests;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AppServices.auth.currentUser ?? UserProfile.defaultDemo();
    _selectedInterests = user.interests.isNotEmpty
        ? user.interests.toSet()
        : {'🛡️ Cybersecurity', '🤖 AI / ML', '🏆 Hackathons'};
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _handleComplete() async {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one interest to personalize your feed.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = AppServices.auth.currentUser ?? UserProfile.defaultDemo();
    final updated = user.copyWith(
      interests: _selectedInterests.toList(),
      isOnboarded: true,
    );

    await AppServices.auth.updateProfile(updated);
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personalize Your Feed'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        showAmbientGlow: true,
        showParticles: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBright,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBright,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step 2 of 2: Technical Domains',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.softLavender),
                      ),
                      const RikoAvatar(
                        expression: RikoExpression.usingTablet,
                        size: 26,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'What are you interested in?',
                    style: AppTextStyles.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Riko will curate hackathons, internships, and mentors tailored to your choices.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Interest Chips Cloud
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return AppChip(
                        label: interest,
                        isSelected: isSelected,
                        onSelected: () => _toggleInterest(interest),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 36),

                  // Submit Button
                  AppButton(
                    text: 'Complete & Enter LinkUp',
                    onPressed: _handleComplete,
                    isLoading: _isLoading,
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
