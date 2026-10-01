import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/empty_state.dart';
import '../widgets/opportunity_card.dart';

/// Screen listing all opportunities bookmarked/saved by the student.
class SavedOpportunitiesScreen extends StatelessWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Opportunities'),
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
              return EmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'No saved opportunities yet',
                description: 'Explore hackathons, internships, and contests, then save the ones you want to revisit before deadlines.',
                actionLabel: 'Explore Opportunities',
                onAction: () => Navigator.of(context).pop(),
              );
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: savedOpps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return OpportunityCard(opportunity: savedOpps[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
