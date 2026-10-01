import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/opportunity.dart';

/// Screen displaying complete details for an opportunity.
class OpportunityDetailScreen extends StatelessWidget {
  final String opportunityId;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
  });

  Future<void> _handleApply(BuildContext context, Opportunity opp) async {
    final uri = Uri.tryParse(opp.registrationUrl);
    bool launched = false;
    if (uri != null) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
    }

    if (!launched && context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(child: Text('Application Portal', style: AppTextStyles.titleLarge)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are applying for:',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(opp.title, style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              Text('Organization: ${opp.organization}', style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your student profile details (Name, College, Department, Interests) will be attached.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application submitted successfully to demo queue!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Submit Application'),
            ),
          ],
        ),
      );
    }
  }

  void _showShareSheet(BuildContext context, Opportunity opp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Opportunity', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text(opp.title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.softTeal,
                child: Icon(Icons.link_rounded, color: AppColors.primaryDark),
              ),
              title: const Text('Copy Opportunity Link', style: AppTextStyles.titleSmall),
              subtitle: Text(opp.registrationUrl, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copied to clipboard!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.softBlue,
                child: Icon(Icons.send_rounded, color: AppColors.secondary),
              ),
              title: const Text('Share to Student Group', style: AppTextStyles.titleSmall),
              subtitle: const Text('Post this to one of your joined communities', style: AppTextStyles.caption),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shared to group discussion!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opp = AppServices.opportunities.getById(opportunityId);

    if (opp == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Opportunity not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showShareSheet(context, opp),
            tooltip: 'Share',
          ),
          ValueListenableBuilder(
            valueListenable: AppServices.auth.userNotifier,
            builder: (context, user, _) {
              final isSaved = user?.savedOpportunityIds.contains(opp.id) ?? false;
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.primary : AppColors.textPrimary,
                ),
                onPressed: () async {
                  final saved = await AppServices.auth.toggleSaveOpportunity(opp.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(saved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                tooltip: isSaved ? 'Remove from Saved' : 'Save',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deadline', style: AppTextStyles.caption),
                    Text(
                      opp.deadline,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: opp.isClosingSoon ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _handleApply(context, opp),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Apply Now', style: AppTextStyles.labelLarge),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Category, Title & Org
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.softTeal,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            opp.category.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            opp.domain,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(opp.title, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(opp.organization, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Key Highlights Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoBlock(
                      icon: Icons.location_on_outlined,
                      label: 'Location & Mode',
                      value: '${opp.location} (${opp.mode})',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoBlock(
                      icon: Icons.military_tech_outlined,
                      label: 'Prize / Stipend',
                      value: opp.salary ?? opp.prize,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description Section
              const Text('About Opportunity', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  opp.description,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
              ),

              const SizedBox(height: 20),

              // Required Skills Section
              const Text('Required Skills & Tech', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opp.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      skill,
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Eligibility Section
              const Text('Eligibility Criteria', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opp.eligibility,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Source & Verification
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verified from ${opp.source}. Applications submitted through direct partner portal.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBlock({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
