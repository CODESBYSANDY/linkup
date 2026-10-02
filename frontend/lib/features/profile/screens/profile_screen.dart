import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
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
        child: ResponsiveContentWrapper(
          maxWidth: 800,
          child: RefreshIndicator(
            onRefresh: () async {
              await AppServices.auth.syncProfileFromBackend();
              await AppServices.opportunities.fetchSavedOpportunities();
              await AppServices.community.fetchSavedPosts();
            },
            color: AppColors.primaryBright,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
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
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: AppRadii.cardRadius,
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
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
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      profile.branch,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark ? AppColors.primaryLight : AppColors.softLavender,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${profile.college} · ${profile.year}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                      ),
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
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Stats Row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const SavedOpportunitiesScreen()),
                                  ),
                                  child: _buildStatItem('${profile.savedOpportunityIds.length}', 'Saved', isDark),
                                ),
                                _buildStatDivider(isDark),
                                _buildStatItem('${profile.savedPostIds.length + 2}', 'Contributions', isDark),
                                _buildStatDivider(isDark),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ConnectionsListScreen()),
                                  ),
                                  child: _buildStatItem('${profile.connectedUserIds.length}', 'Connections', isDark),
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
                      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                      borderRadius: AppRadii.cardRadius,
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
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
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '3 opportunities tracked this week',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark ? AppColors.primaryLight : AppColors.softLavender,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Skills & Tech
                  Text(
                    'Skills & Tech',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Text(
                          skill,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Technical Interests',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : const Color(0xFFEDE9FE),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Library & Activity
                  Text(
                    'Library & Activity',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildNavigationTile(
                    context,
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
                    context,
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
                    context,
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
                    context,
                    icon: Icons.settings_outlined,
                    iconColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    iconBg: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
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
  ),
);
}

  Widget _buildStatItem(String value, String label, bool isDark) {
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
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark ? AppColors.darkBorder : AppColors.border,
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: AppRadii.cardRadius,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
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
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
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
                color: isDark ? AppColors.darkTextMuted : AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

