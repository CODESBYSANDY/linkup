import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../opportunities/widgets/opportunity_card.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../connect/widgets/person_card.dart';
import 'search_screen.dart';

/// Interactive Home screen representing the primary discovery hub.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Hackathons',
    'Internships',
    'Jobs',
    'Competitions',
    'Workshops',
    'Events',
  ];

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
                final filteredOpps = _selectedCategory == 'All'
                    ? allOpps
                    : allOpps.where((o) => o.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

                final featuredOpp = allOpps.firstWhere((o) => o.isFeatured, orElse: () => allOpps.first);
                final closingSoonOpps = allOpps.where((o) => o.isClosingSoon).toList();
                final latestOpps = filteredOpps.take(6).toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: User Greeting & Notification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good evening, $userName 👋',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Find your next opportunity',
                                  style: AppTextStyles.displaySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ValueListenableBuilder(
                            valueListenable: AppServices.notifications.notificationsNotifier,
                            builder: (context, notifs, _) {
                              final unreadCount = AppServices.notifications.unreadCount;
                              return Stack(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: AppColors.textPrimary,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                        );
                                      },
                                      tooltip: 'Notifications',
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: AppColors.textInverse,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Interactive Search Bar Preview
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search opportunities, people & topics...',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.softTeal,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: AppColors.primaryDark,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Category Filter Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedCategory = cat);
                                },
                                backgroundColor: AppColors.surface,
                                selectedColor: AppColors.softTeal,
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                                labelStyle: AppTextStyles.labelMedium.copyWith(
                                  color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Featured Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Featured Opportunity', style: AppTextStyles.headlineSmall),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SearchScreen()),
                              );
                            },
                            child: Text(
                              'View all',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Featured Opportunity Banner Card
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OpportunityDetailScreen(opportunityId: featuredOpp.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.code_rounded,
                                      color: AppColors.primary,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${featuredOpp.category.toUpperCase()} · ${featuredOpp.mode.toUpperCase()}',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.primaryLight,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          featuredOpp.title,
                                          style: AppTextStyles.titleLarge.copyWith(
                                            color: AppColors.textInverse,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Hosted by ${featuredOpp.organization}',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                featuredOpp.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFFCBD5E1),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 16,
                                        color: AppColors.warning,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Deadline: ${featuredOpp.deadline}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Explore Details',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.textInverse,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Closing Soon Section
                      if (closingSoonOpps.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Closing Soon 🔥', style: AppTextStyles.headlineSmall),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                                );
                              },
                              child: Text(
                                'See all',
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...closingSoonOpps.map((opp) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OpportunityCard(opportunity: opp),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Latest Opportunities Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Opportunities (${filteredOpps.length})', style: AppTextStyles.headlineSmall),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...latestOpps.map((opp) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OpportunityCard(opportunity: opp),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Recommended Peers Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Students with Matching Skills', style: AppTextStyles.headlineSmall),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...AppServices.connect.allPeople.take(2).map((peer) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PersonCard(person: peer),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
