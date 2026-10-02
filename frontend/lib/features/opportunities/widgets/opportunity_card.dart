import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../data/models/opportunity.dart';
import '../../../data/models/user_profile.dart';
import '../screens/opportunity_detail_screen.dart';

/// Reusable Opportunity Card matching Image 2 & Image 4:
/// - Light style (default): Crisp white rounded card with subtle border,
///   organization logo, title, organization, orange deadline, badges, and bookmark.
/// - Featured style: Sleek dark navy card for "Featured for you" hero carousel.
class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isFeaturedStyle;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.isFeaturedStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFeaturedStyle) {
      return _buildFeaturedCard(context);
    }
    return _buildStandardCard(context);
  }

  Widget _buildStandardCard(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
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
            borderRadius: BorderRadius.circular(18),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final cardBg = isDark ? AppColors.darkSurface : Colors.white;
                final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
                final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
                final orgColor = isDark ? AppColors.darkTextMuted : const Color(0xFF64748B);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x060F172A),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Organization Brand Logo
                      CompanyLogo(
                        organization: opportunity.organization,
                        size: 46,
                      ),
                      const SizedBox(width: 12),

                      // Middle Content: Title, Org, Deadline, Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              opportunity.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                                fontSize: 14.5,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),

                            // Organization Name
                            Text(
                              opportunity.organization,
                              style: TextStyle(
                                color: orgColor,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Deadline in X days (Orange accent per reference)
                            Text(
                              'Deadline in ${opportunity.daysLeft} days',
                              style: const TextStyle(
                                color: Color(0xFFEA580C), // Orange per reference
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Badges Row: Mode, Event Type, Prize
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildPillBadge(context, opportunity.mode),
                                _buildPillBadge(
                                  context,
                                  opportunity.category == 'Hackathons'
                                      ? 'Team Event'
                                      : opportunity.category,
                                ),
                                if (opportunity.prize.isNotEmpty)
                                  _buildPillBadge(context, opportunity.prize),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bookmark Button
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isSaved
                              ? AppColors.primary
                              : (isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8)),
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          AppServices.auth.toggleSaveOpportunity(opportunity.id);
                        },
                        tooltip: isSaved ? 'Remove from Saved' : 'Save Opportunity',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
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
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF101333), // Deep Navy background per reference
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20101333),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Organization Logo
                      CompanyLogo(
                        organization: opportunity.organization,
                        size: 48,
                      ),
                      const SizedBox(width: 14),

                      // Title & Org
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opportunity.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              opportunity.organization,
                              style: const TextStyle(
                                color: Color(0xFFAAB2D5),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Deadline in ${opportunity.daysLeft} days',
                              style: const TextStyle(
                                color: Color(0xFFF97316), // Vivid Orange
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bookmark button
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          AppServices.auth.toggleSaveOpportunity(opportunity.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Translucent Badges Row per reference
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildDarkPillBadge(Icons.radio_button_checked_rounded, opportunity.mode),
                      _buildDarkPillBadge(
                        Icons.school_rounded,
                        opportunity.category == 'Hackathons'
                            ? 'Team Event'
                            : opportunity.category,
                      ),
                      if (opportunity.prize.isNotEmpty)
                        _buildDarkPillBadge(Icons.emoji_events_rounded, opportunity.prize),
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

  Widget _buildPillBadge(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillBg = isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9);
    final textCol = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textCol,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDarkPillBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
