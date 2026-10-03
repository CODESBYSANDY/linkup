import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../data/models/opportunity.dart';
import '../widgets/opportunity_card.dart';
import 'explore_screen.dart';

/// Screen 5: Saved Opportunities Screen
/// Matches the reference design with clean white cards and friendly Riko empty state.
class SavedOpportunitiesScreen extends StatefulWidget {
  final bool showBackButton;

  const SavedOpportunitiesScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<SavedOpportunitiesScreen> createState() => _SavedOpportunitiesScreenState();
}

class _SavedOpportunitiesScreenState extends State<SavedOpportunitiesScreen> {
  @override
  void initState() {
    super.initState();
    AppServices.opportunities.fetchSavedOpportunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text(
          'Saved Opportunities',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContentWrapper(
          maxWidth: 1200,
          child: ValueListenableBuilder<List<Opportunity>>(
            valueListenable: AppServices.opportunities.savedOpportunitiesNotifier,
            builder: (context, savedOpps, _) {
              if (savedOpps.isEmpty) {
                return Center(
                  child: RikoEmptyState(
                    expression: RikoExpression.sitting,
                    title: 'Nothing saved yet',
                    message: "Save hackathons, internships, and opportunities you want to track or apply to later!",
                    actionLabel: 'Explore Opportunities',
                    actionIcon: Icons.explore_rounded,
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ExploreScreen()),
                      );
                    },
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await AppServices.opportunities.fetchSavedOpportunities();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        '${savedOpps.length} bookmarked ${savedOpps.length == 1 ? "opportunity" : "opportunities"}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: savedOpps.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return OpportunityCard(opportunity: savedOpps[index]);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
