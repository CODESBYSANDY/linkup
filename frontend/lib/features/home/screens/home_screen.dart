import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/widgets/riko_header_avatar.dart';
import '../../../core/widgets/riko_recommendation_card.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../opportunities/screens/explore_screen.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';
import '../../opportunities/widgets/opportunity_card.dart';
import 'search_screen.dart';

/// Screen 2: LINKUP Home Screen
/// Faithfully reproduces Image 2 (Left) from the reference design:
/// - Header: "Good evening, Sandeep! 👋" + Riko peeking mascot + notification bell with unread dot
/// - Search Bar: "Search opportunities..." with purple filter button
/// - Category Shortcuts: 4 clean cards (Hackathons, Internships, Jobs, Events)
/// - Riko Recommendation Card: "Psst... I found a new hackathon you might like! 🎯" + 3D Riko
/// - "Featured for you" with View All: Dark sleek featured card with page dots
/// - "Latest Hackathons" with View All: Clean white opportunity cards with badges
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

  void _onCategoryTap(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExploreScreen(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContentWrapper(
          maxWidth: 1200,
          child: ValueListenableBuilder(
            valueListenable: AppServices.auth.userNotifier,
            builder: (context, user, _) {
              final userName = (user?.name.trim().isNotEmpty ?? false)
                  ? user!.name.trim().split(' ').first
                  : 'Student';

              return ValueListenableBuilder(
                valueListenable: AppServices.opportunities.opportunitiesNotifier,
                builder: (context, allOpps, _) {
                  final featuredOpp = allOpps.isNotEmpty
                      ? allOpps.firstWhere((o) => o.isFeatured, orElse: () => allOpps.first)
                      : null;

                  final hackathons = allOpps.where((o) => o.category == 'Hackathons').toList();
                  final displayHackathons = hackathons.isNotEmpty ? hackathons : allOpps;

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
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
                          // Top Row: Greeting & Riko Avatar + Notification Bell
                          _buildHeaderRow(userName),

                          const SizedBox(height: 18),

                          // Search Bar with Filter
                          AppSearchBar(
                            readOnly: true,
                            hintText: 'Search opportunities...',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SearchScreen()),
                              );
                            },
                            onFilterTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ExploreScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Category Shortcuts (Hackathons, Internships, Jobs, Events)
                          _buildCategoryShortcuts(),

                          const SizedBox(height: 20),

                          // Riko Recommendation Card
                          RikoRecommendationCard(
                            title: 'Psst... I found a new\nhackathon you might like! 🎯',
                            subtitle: 'Based on your interests in\nAI and Cybersecurity',
                            buttonText: 'View Recommendation →',
                            onTap: () {
                              if (featuredOpp != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OpportunityDetailScreen(opportunityId: featuredOpp.id),
                                  ),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 24),

                          // "Featured for you" Header
                          if (featuredOpp != null) ...[
                            _buildSectionHeader(
                              title: 'Featured for you',
                              onViewAll: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ExploreScreen(initialCategory: 'Hackathons'),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Featured Dark Hero Card
                            OpportunityCard(
                              opportunity: featuredOpp,
                              isFeaturedStyle: true,
                            ),
                            const SizedBox(height: 12),
                            // Carousel Dots Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDot(isActive: true),
                                _buildDot(isActive: false),
                                _buildDot(isActive: false),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],

                          // "Latest Hackathons" Header
                          _buildSectionHeader(
                            title: 'Latest Hackathons',
                            onViewAll: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ExploreScreen(initialCategory: 'Hackathons'),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // Latest Hackathons List
                          if (displayHackathons.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.event_note_outlined, size: 40, color: Color(0xFF94A3B8)),
                                  SizedBox(height: 8),
                                  Text(
                                    'No opportunities available right now',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayHackathons.take(4).length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return OpportunityCard(opportunity: displayHackathons[index]);
                              },
                            ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting & Name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '$userName! 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right side: Waving Riko & Notification Bell per reference
        Row(
          children: [
            // Peeking Riko Avatar
            const RikoHeaderAvatar(size: 46),

            const SizedBox(width: 10),

            // Notification Bell with unread dot in white rounded box
            ValueListenableBuilder(
              valueListenable: AppServices.notifications.notificationsNotifier,
              builder: (context, notifs, _) {
                final unreadCount = AppServices.notifications.unreadCount;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 10,
                            right: 11,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryShortcuts() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryCard(
          title: 'Hackathons',
          icon: Icons.school_rounded,
          bgColor: const Color(0xFFEDE9FE), // Soft purple
          iconColor: const Color(0xFF7C3AED),
          onTap: () => _onCategoryTap('Hackathons'),
        ),
        _buildCategoryCard(
          title: 'Internships',
          icon: Icons.work_rounded,
          bgColor: const Color(0xFFDCFCE7), // Soft green
          iconColor: const Color(0xFF16A34A),
          onTap: () => _onCategoryTap('Internships'),
        ),
        _buildCategoryCard(
          title: 'Jobs',
          icon: Icons.business_center_rounded,
          bgColor: const Color(0xFFFEE2E2), // Soft coral/red
          iconColor: const Color(0xFFDC2626),
          onTap: () => _onCategoryTap('Jobs'),
        ),
        _buildCategoryCard(
          title: 'Events',
          icon: Icons.event_rounded,
          bgColor: const Color(0xFFDBEAFE), // Soft blue
          iconColor: const Color(0xFF2563EB),
          onTap: () => _onCategoryTap('Events'),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x040F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
