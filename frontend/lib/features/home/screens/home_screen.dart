import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../opportunities/widgets/opportunity_card.dart';
import '../../opportunities/screens/explore_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../assistant/screens/riko_assistant_screen.dart';
import 'search_screen.dart';

/// Primary Home discovery hub matching the Riko visual design system.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: AppServices.auth.userNotifier,
          builder: (context, user, _) {
            final userName = user?.name.split(' ').first ?? 'Sandeep';

            return ValueListenableBuilder(
              valueListenable: AppServices.opportunities.opportunitiesNotifier,
              builder: (context, allOpps, _) {
                final featuredOpp = allOpps.isNotEmpty
                    ? allOpps.firstWhere((o) => o.isFeatured, orElse: () => allOpps.first)
                    : null;

                final hackathons = allOpps.where((o) => o.category == 'Hackathons').toList();
                final displayHackathons = hackathons.isNotEmpty ? hackathons : allOpps;

                return RefreshIndicator(
                  color: AppColors.primaryBright,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    await Future.wait([
                      AppServices.opportunities.fetchOpportunities(isRefresh: true),
                      AppServices.notifications.fetchNotifications(),
                    ]);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Top Row: Greeting & Riko Avatar + Notifications
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '$userName! 👋',
                                    style: AppTextStyles.displaySmall.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Notification Bell
                              ValueListenableBuilder(
                                valueListenable: AppServices.notifications.notificationsNotifier,
                                builder: (context, notifs, _) {
                                  final unreadCount = AppServices.notifications.unreadCount;
                                  return Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.notifications_none_rounded,
                                          color: AppColors.textSecondary,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                          );
                                        },
                                        tooltip: 'Notifications',
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryBright,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              // Riko Scout Avatar Button -> Opens Assistant
                              RikoAvatar(
                                expression: RikoExpression.happy,
                                size: 44,
                                showGlow: true,
                                showBadge: true,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RikoAssistantScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Search Bar
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          );
                        },
                        borderRadius: AppRadii.inputRadius,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: AppRadii.inputRadius,
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: AppColors.softLavender,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search opportunities...',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.tune_rounded,
                                color: AppColors.softLavender,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Category Shortcuts (4 Modern Tiles)
                      Row(
                        children: [
                          _buildCategoryShortcut(
                            label: 'Hackathons',
                            icon: Icons.code_rounded,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => _navigateToExploreWithFilter('Hackathons'),
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryShortcut(
                            label: 'Internships',
                            icon: Icons.work_outline_rounded,
                            color: const Color(0xFF10B981),
                            onTap: () => _navigateToExploreWithFilter('Internships'),
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryShortcut(
                            label: 'Jobs',
                            icon: Icons.badge_outlined,
                            color: const Color(0xFFEF4444),
                            onTap: () => _navigateToExploreWithFilter('Jobs'),
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryShortcut(
                            label: 'Events',
                            icon: Icons.event_available_outlined,
                            color: const Color(0xFF38BDF8),
                            onTap: () => _navigateToExploreWithFilter('Events'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Riko Smart Scout In-App Suggestion Card
                      _buildRikoScoutBanner(),

                      const SizedBox(height: 24),

                      // Featured For You Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured for you',
                            style: AppTextStyles.headlineSmall,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SearchScreen()),
                              );
                            },
                            child: Text(
                              'View All',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.softLavender,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Featured Opportunity Card
                      if (featuredOpp != null)
                        OpportunityCard(
                          opportunity: featuredOpp,
                          isFeaturedStyle: true,
                        ),

                      const SizedBox(height: 24),

                      // Latest Hackathons Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Latest Hackathons',
                            style: AppTextStyles.headlineSmall,
                          ),
                          TextButton(
                            onPressed: () => _navigateToExploreWithFilter('Hackathons'),
                            child: Text(
                              'View All',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.softLavender,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Opportunity Cards List
                      ...displayHackathons.take(4).map((opp) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OpportunityCard(opportunity: opp),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}

  Widget _buildCategoryShortcut({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.chipRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: AppRadii.chipRadius,
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRikoScoutBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF26194F), Color(0xFF13173D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: AppColors.primaryBright.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const RikoAvatar(
            expression: RikoExpression.laptop,
            size: 44,
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
                      'Riko Scout',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.softLavender,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.auto_awesome, size: 12, color: AppColors.primaryBright),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Riko has 3 new opportunities matching your profile!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryLight),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RikoAssistantScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToExploreWithFilter(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExploreScreen(initialCategory: category),
      ),
    );
  }
}
