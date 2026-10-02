import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../core/widgets/riko_header_avatar.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../widgets/opportunity_card.dart';

/// Screen 3: LINKUP Explore Screen
/// Faithfully reproduces Image 2 (Right) from the reference design:
/// - Top Bar: "Explore" title + Riko peeking mascot + notification bell
/// - Search Bar: "Search opportunities..." with filter button
/// - Filter Chips: All (active purple pill), Hackathons, Internships, Jobs, Events
/// - Vertical Opportunity List: Clean white cards with authentic company logos,
///   orange deadline, tags, prize, and bookmark button
class ExploreScreen extends StatefulWidget {
  final String initialCategory;

  const ExploreScreen({
    super.key,
    this.initialCategory = 'All',
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final TextEditingController _searchController;
  late String _selectedCategory;

  final List<String> _categories = const [
    'All',
    'Hackathons',
    'Internships',
    'Jobs',
    'Events',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContentWrapper(
          maxWidth: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar: "Explore" + Riko Avatar + Notification Bell
              _buildHeader(),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search opportunities...',
                  onChanged: (_) => setState(() {}),
                  onFilterTap: () => _showFilterBottomSheet(context),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: cat,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Opportunities List
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: AppServices.opportunities.opportunitiesNotifier,
                  builder: (context, allOpps, _) {
                    final query = _searchController.text.trim().toLowerCase();

                    final filtered = allOpps.where((opp) {
                      final matchesCategory = _selectedCategory == 'All' || opp.category == _selectedCategory;
                      final matchesQuery = query.isEmpty ||
                          opp.title.toLowerCase().contains(query) ||
                          opp.organization.toLowerCase().contains(query) ||
                          opp.skills.any((s) => s.toLowerCase().contains(query)) ||
                          opp.domain.toLowerCase().contains(query);
                      return matchesCategory && matchesQuery;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: RikoEmptyState(
                          expression: RikoExpression.thinking,
                          title: 'No opportunities found',
                          message: "Riko couldn't find any opportunities matching '$_selectedCategory'. Try adjusting your search query or filters!",
                          actionLabel: 'Reset Filters',
                          actionIcon: Icons.refresh_rounded,
                          onAction: () {
                            setState(() {
                              _selectedCategory = 'All';
                              _searchController.clear();
                            });
                          },
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        await AppServices.opportunities.fetchOpportunities(isRefresh: true);
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return OpportunityCard(opportunity: filtered[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "Explore" title
          const Text(
            'Explore',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),

          // Right: Riko peeking avatar & notification bell
          Row(
            children: [
              const RikoHeaderAvatar(size: 44),
              const SizedBox(width: 10),
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
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Opportunities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return AppChip(
                    label: cat,
                    isSelected: isSel,
                    onSelected: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      Navigator.of(ctx).pop();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
