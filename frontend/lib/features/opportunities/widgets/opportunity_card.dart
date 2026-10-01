import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/opportunity.dart';
import '../screens/opportunity_detail_screen.dart';

/// Reusable interactive Opportunity Card.
class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityCard({
    super.key,
    required this.opportunity,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hackathons':
        return Icons.code_rounded;
      case 'internships':
      case 'jobs':
        return Icons.work_outline_rounded;
      case 'competitions':
        return Icons.emoji_events_outlined;
      case 'workshops':
        return Icons.bolt_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        final isSaved = user?.savedOpportunityIds.contains(opportunity.id) ?? false;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OpportunityDetailScreen(opportunityId: opportunity.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category badge, Mode & Bookmark Button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.softTeal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(opportunity.category),
                            size: 14,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            opportunity.category.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        opportunity.mode,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? AppColors.primary : AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: () async {
                        final saved = await AppServices.auth.toggleSaveOpportunity(opportunity.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(saved ? 'Saved to your bookmarks' : 'Removed from bookmarks'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.textPrimary,
                            ),
                          );
                        }
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: isSaved ? 'Remove from Saved' : 'Save Opportunity',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  opportunity.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Organization & Location
                Text(
                  '${opportunity.organization} · ${opportunity.location}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  opportunity.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // Skills tags wrap
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: opportunity.skills.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        skill,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),

                // Bottom Row: Prize / Salary & Deadline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        opportunity.salary ?? opportunity.prize,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: opportunity.isClosingSoon ? AppColors.error : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          opportunity.deadline,
                          style: AppTextStyles.caption.copyWith(
                            color: opportunity.isClosingSoon ? AppColors.error : AppColors.textSecondary,
                            fontWeight: opportunity.isClosingSoon ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
