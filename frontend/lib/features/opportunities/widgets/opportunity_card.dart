import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/opportunity.dart';
import '../screens/opportunity_detail_screen.dart';

/// Reusable Opportunity Card matching the Riko visual design language.
class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isFeaturedStyle;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.isFeaturedStyle = false,
  });

  Widget _buildOrgLogo(String org, String category) {
    Color bg;
    String label;
    if (org.toLowerCase().contains('google')) {
      bg = const Color(0xFF1E293B);
      label = 'G';
    } else if (org.toLowerCase().contains('flipkart')) {
      bg = const Color(0xFF2874F0);
      label = 'fk';
    } else if (org.toLowerCase().contains('isro')) {
      bg = const Color(0xFFFF6D00);
      label = 'ISRO';
    } else if (org.toLowerCase().contains('tcs') || org.toLowerCase().contains('tata')) {
      bg = const Color(0xFF00838F);
      label = 'TCS';
    } else if (org.toLowerCase().contains('microsoft')) {
      bg = const Color(0xFF00A4EF);
      label = 'MS';
    } else if (org.toLowerCase().contains('aws') || org.toLowerCase().contains('unstop')) {
      bg = const Color(0xFF232F3E);
      label = 'AWS';
    } else if (org.toLowerCase().contains('iit')) {
      bg = const Color(0xFF6B21A8);
      label = 'IIT';
    } else {
      bg = AppColors.surfaceElevated;
      label = org.isNotEmpty ? org.substring(0, org.length > 2 ? 2 : org.length).toUpperCase() : 'OP';
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        final isSaved = user?.savedOpportunityIds.contains(opportunity.id) ?? false;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OpportunityDetailScreen(opportunityId: opportunity.id),
                ),
              );
            },
            borderRadius: AppRadii.cardRadius,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFeaturedStyle ? const Color(0xFF141738) : AppColors.surface,
                borderRadius: AppRadii.cardRadius,
                border: Border.all(
                  color: isFeaturedStyle
                      ? AppColors.primaryBright.withValues(alpha: 0.35)
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Org Logo + Title & Details + Bookmark
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrgLogo(opportunity.organization, opportunity.category),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opportunity.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              opportunity.organization,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Deadline text with badge styling
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: opportunity.daysLeft <= 5 ? AppColors.warning : AppColors.softLavender,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Deadline in ${opportunity.daysLeft} days',
                                  style: AppTextStyles.caption.copyWith(
                                    color: opportunity.daysLeft <= 5 ? AppColors.warning : AppColors.softLavender,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isSaved ? AppColors.primaryBright : AppColors.textMuted,
                          size: 22,
                        ),
                        onPressed: () async {
                          final saved = await AppServices.auth.toggleSaveOpportunity(opportunity.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(saved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
                                duration: const Duration(milliseconds: 900),
                                backgroundColor: AppColors.surfaceElevated,
                              ),
                            );
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: isSaved ? 'Remove from Saved' : 'Save',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bottom Tags Row: Mode, Category, Stipend/Prize
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildTag(opportunity.mode, isPrimary: false),
                      _buildTag(
                        opportunity.category == 'Hackathons'
                            ? 'Team Event'
                            : (opportunity.category == 'Internships' ? 'Internship' : opportunity.category),
                        isPrimary: false,
                      ),
                      _buildTag(
                        opportunity.salary ?? opportunity.prize,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String label, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.18)
            : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary
              ? AppColors.primaryBright.withValues(alpha: 0.35)
              : AppColors.borderSubtle,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isPrimary ? AppColors.primaryLight : AppColors.textMuted,
          fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}
