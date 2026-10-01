import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../data/models/user_profile.dart';
import '../../opportunities/screens/saved_opportunities_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../settings/screens/settings_screen.dart';
import 'edit_profile_screen.dart';
import 'connections_list_screen.dart';

/// Screen displaying the student's personal profile, library, and settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await AppServices.auth.syncProfileFromBackend();
            await AppServices.opportunities.fetchSavedOpportunities();
            await AppServices.community.fetchSavedPosts();
          },
          color: AppColors.primaryBright,
          backgroundColor: AppColors.surface,
          child: ValueListenableBuilder(
            valueListenable: AppServices.auth.userNotifier,
            builder: (context, user, _) {
              final profile = user ?? UserProfile.defaultDemo();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.cardRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.6), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  profile.avatarInitials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: AppTextStyles.titleLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    profile.branch,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.softLavender,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${profile.college} · ${profile.year}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (profile.bio.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            profile.bio,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Stats Row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SavedOpportunitiesScreen()),
                                ),
                                child: _buildStatItem('${profile.savedOpportunityIds.length}', 'Saved'),
                              ),
                              _buildStatDivider(),
                              _buildStatItem('${profile.savedPostIds.length + 2}', 'Contributions'),
                              _buildStatDivider(),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ConnectionsListScreen()),
                                ),
                                child: _buildStatItem('${profile.connectedUserIds.length}', 'Connections'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scout Guide Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: AppRadii.cardRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const RikoAvatar(
                          expression: RikoExpression.celebrating,
                          size: 38,
                          showGlow: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riko Scout Level: Explorer',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '3 opportunities tracked this week',
                                style: AppTextStyles.caption.copyWith(color: AppColors.softLavender),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Skills & Tech
                  const Text('Skills & Tech', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          skill,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  const Text('Technical Interests', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          interest,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Library & Activity
                  const Text('Library & Activity', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),

                  _buildNavigationTile(
                    icon: Icons.bookmark_added_outlined,
                    iconColor: AppColors.primaryBright,
                    iconBg: AppColors.primary.withValues(alpha: 0.15),
                    title: 'Saved Opportunities',
                    subtitle: '${profile.savedOpportunityIds.length} bookmarked items',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedOpportunitiesScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildNavigationTile(
                    icon: Icons.people_outline_rounded,
                    iconColor: AppColors.secondaryLight,
                    iconBg: AppColors.secondary.withValues(alpha: 0.15),
                    title: 'My Network & Connections',
                    subtitle: '${profile.connectedUserIds.length} peers connected',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ConnectionsListScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildNavigationTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.warning,
                    iconBg: AppColors.warningSoft,
                    title: 'Notifications',
                    subtitle: 'Activity updates and deadline alerts',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildNavigationTile(
                    icon: Icons.settings_outlined,
                    iconColor: AppColors.textMuted,
                    iconBg: AppColors.surfaceSecondary,
                    title: 'Settings & Appearance',
                    subtitle: 'Theme, account visibility, and preferences',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.primaryBright,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.cardRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
