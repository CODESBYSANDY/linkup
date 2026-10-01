import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../widgets/opportunity_card.dart';
import 'explore_screen.dart';

/// Screen listing all opportunities bookmarked/saved by the student.
class SavedOpportunitiesScreen extends StatelessWidget {
  final bool showBackButton;

  const SavedOpportunitiesScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        title: Text(
          'Saved Opportunities',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: AppServices.auth.userNotifier,
          builder: (context, user, _) {
            final savedIds = user?.savedOpportunityIds ?? [];
            final savedOpps = AppServices.opportunities.allOpportunities
                .where((opp) => savedIds.contains(opp.id))
                .toList();

            if (savedOpps.isEmpty) {
              return RikoEmptyState(
                expression: RikoExpression.sitting,
                title: 'No saved opportunities yet',
                message: "Riko hasn't found any saved bookmarks in your scout library. Let's find something interesting!",
                actionLabel: 'Explore Opportunities',
                actionIcon: Icons.explore_rounded,
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExploreScreen()),
                  );
                },
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    '${savedOpps.length} bookmarked opportunities',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.softLavender),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: savedOpps.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return OpportunityCard(opportunity: savedOpps[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
