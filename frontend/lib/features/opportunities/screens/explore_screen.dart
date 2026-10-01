import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../widgets/opportunity_card.dart';

/// Dedicated Explore Screen matching Reference Showcase Screen 4.
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore',
                    style: AppTextStyles.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppColors.softLavender),
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                    tooltip: 'Filters',
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: AppSearchBar(
                controller: _searchController,
                hintText: 'Search opportunities...',
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: cat,
                      isSelected: isSelected,
                      onSelected: () => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 6),

            // Opportunity List Stream / State
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: AppServices.opportunities.opportunitiesNotifier,
                builder: (context, allOpps, _) {
                  final query = _searchController.text.trim();
                  final filtered = AppServices.opportunities.filterOpportunities(
                    query: query,
                    category: _selectedCategory,
                  );

                  if (filtered.isEmpty) {
                    return RikoEmptyState(
                      expression: RikoExpression.thinking,
                      title: 'No opportunities found',
                      message: 'Riko could not find opportunities matching "$query". Try changing your search or filters.',
                      actionLabel: 'Clear Filters',
                      actionIcon: Icons.refresh_rounded,
                      onAction: () {
                        setState(() {
                          _searchController.clear();
                          _selectedCategory = 'All';
                        });
                      },
                    );
                  }

                    return RefreshIndicator(
                      color: AppColors.primaryBright,
                      backgroundColor: AppColors.surface,
                      onRefresh: () async {
                        await AppServices.opportunities.fetchOpportunities(
                          category: _selectedCategory,
                          query: query,
                          isRefresh: true,
                        );
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final opp = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OpportunityCard(opportunity: opp),
                          );
                        },
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceSecondary,
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
                  const Text('Filter Opportunities', style: AppTextStyles.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Category', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return AppChip(
                    label: cat,
                    isSelected: isSelected,
                    onSelected: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(ctx);
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
