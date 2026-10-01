import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../profile/screens/edit_profile_screen.dart';

/// Screen allowing configuration of application preferences, theme, and account state.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Account Section
            const Text('Account', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),

            _buildSettingTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Student Profile',
              subtitle: 'Update name, college, year, bio, and skills',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),

            const SizedBox(height: 8),

            _buildSettingTile(
              icon: Icons.alternate_email_rounded,
              title: 'Registered Email',
              subtitle: AppServices.auth.currentUser?.email ?? 'sandeep@student.linkup.dev',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Appearance & Theme Section
            const Text('Appearance', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),

            ValueListenableBuilder<ThemeMode>(
              valueListenable: AppServices.themeModeNotifier,
              builder: (context, currentMode, _) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
                          const SizedBox(width: 12),
                          Text('Theme Mode', style: AppTextStyles.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_outlined),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_outlined),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.phone_android_outlined),
                          ),
                        ],
                        selected: {currentMode},
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
            const Text('Community & Privacy', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),

            _buildSettingTile(
              icon: Icons.visibility_outlined,
              title: 'Profile Visibility',
              subtitle: 'Visible to students from your college & network',
              onTap: () {},
            ),

            const SizedBox(height: 8),

            _buildSettingTile(
              icon: Icons.rule_folder_outlined,
              title: 'Community Code of Conduct',
              subtitle: 'Peer collaboration and knowledge guidelines',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Community Guidelines'),
                    content: const Text(
                      '1. Be collaborative and constructive.\n2. Respect student peers and mentors.\n3. Share verified technical knowledge and opportunities.\n4. Strictly zero harassment or spam.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Got it')),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // About Section
            const Text('About', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),

            _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: 'LinkUp Version',
              subtitle: 'v2.0.0 (Interactive Prototype)',
              onTap: () {},
            ),

            const SizedBox(height: 28),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out of LinkUp?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Sign Out'),
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
                backgroundColor: AppColors.errorSoft,
                foregroundColor: AppColors.error,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
