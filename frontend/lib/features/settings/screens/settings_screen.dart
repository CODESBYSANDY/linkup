import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../profile/screens/edit_profile_screen.dart';

/// Screen allowing configuration of application preferences, theme, and account state.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings & Preferences',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: AppBackground(
        showGlows: true,
        child: SafeArea(
          child: ResponsiveContentWrapper(
            maxWidth: 800,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Riko Scout Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        isDark ? AppColors.darkSurface : AppColors.cardBackground,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const RikoAvatar(
                        expression: RikoExpression.happy,
                        size: 48,
                        showGlow: true,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Riko Scout Active',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Personalized opportunities & deadline tracking enabled.',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.primaryLight : AppColors.lavender,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Account Section
                Text(
                  'Account',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Student Profile',
                  subtitle: 'Update name, college, year, bio, and skills',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildSettingTile(
                  context,
                  icon: Icons.alternate_email_rounded,
                  title: 'Registered Email',
                  subtitle: AppServices.auth.currentUser?.email ?? 'sandeep@student.linkup.dev',
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Appearance & Theme Section
                Text(
                  'Appearance',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppServices.themeModeNotifier,
                  builder: (context, currentMode, _) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.palette_outlined,
                                  color: AppColors.primaryBright,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Theme Mode',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text('Dark'),
                                icon: Icon(Icons.dark_mode_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text('Light'),
                                icon: Icon(Icons.light_mode_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text('System'),
                                icon: Icon(Icons.phone_android_outlined, size: 16),
                              ),
                            ],
                            selected: {currentMode},
                            style: SegmentedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.surface,
                              selectedBackgroundColor: AppColors.primaryBright,
                              foregroundColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              selectedForegroundColor: AppColors.textInverse,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.cardBorder),
                            ),
                            onSelectionChanged: (newSelection) {
                              AppServices.setThemeMode(newSelection.first);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Privacy & Community Guidelines
                Text(
                  'Community & Privacy',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  context,
                  icon: Icons.visibility_outlined,
                  title: 'Profile Visibility',
                  subtitle: 'Visible to student network and mentors',
                  onTap: () {},
                ),

                const SizedBox(height: 10),

                _buildSettingTile(
                  context,
                  icon: Icons.rule_folder_outlined,
                  title: 'Community Code of Conduct',
                  subtitle: 'Peer collaboration & verified opportunity rules',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.cardBorder),
                        ),
                        title: Text(
                          'Community Guidelines',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        content: Text(
                          '1. Be collaborative, constructive, and respectful.\n2. Share verified student opportunities and hackathons.\n3. Zero tolerance for spam, misleading listings, or harassment.\n4. Support peers in their career and skill growth.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Got it', style: TextStyle(color: AppColors.primaryBright)),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // About Section
                Text(
                  'About',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  title: 'LINKUP V3',
                  subtitle: 'Riko Edition · Your Opportunity Scout',
                  onTap: () {},
                ),

                const SizedBox(height: 32),

                // Logout Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.cardBorder),
                          ),
                          title: Text(
                            'Sign Out',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to sign out of LinkUp?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await AppServices.auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                        }
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out', style: AppTextStyles.labelLarge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.15),
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.lavender, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

