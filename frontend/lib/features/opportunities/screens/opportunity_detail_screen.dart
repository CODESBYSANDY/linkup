import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/opportunity.dart';

/// Screen displaying Opportunity Details matching Reference Showcase Screen 5.
class OpportunityDetailScreen extends StatefulWidget {
  final String opportunityId;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDescriptionExpanded = false;

  final List<String> _tabs = const ['Details', 'Eligibility', 'Timeline', 'More'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleApply(Opportunity opp) async {
    final uri = Uri.tryParse(opp.registrationUrl);
    bool launched = false;
    if (uri != null) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
    }

    if (!launched && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryBright),
              const SizedBox(width: 8),
              const Expanded(child: Text('Apply to Opportunity', style: AppTextStyles.titleLarge)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(opp.title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 6),
              Text('Organization: ${opp.organization}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Your student profile (Name, College, Skills) is ready to be submitted.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.softLavender),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application recorded in student scout history!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Confirm Application'),
            ),
          ],
        ),
      );
    }
  }

  void _showShareSheet(Opportunity opp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Opportunity', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text(opp.title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.link_rounded, color: AppColors.primaryBright),
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
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.forum_outlined, color: AppColors.secondaryLight),
              ),
              title: const Text('Share to Community Forum', style: AppTextStyles.titleSmall),
              subtitle: const Text('Start a discussion or form a hackathon team', style: AppTextStyles.caption),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shared to Community!'),
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

  Widget _buildOrgLogo(String org) {
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
    } else {
      bg = AppColors.surfaceElevated;
      label = org.isNotEmpty ? org.substring(0, org.length > 2 ? 2 : org.length).toUpperCase() : 'OP';
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opp = AppServices.opportunities.getById(widget.opportunityId) ??
        AppServices.opportunities.allOpportunities.firstWhere(
          (o) => o.id == widget.opportunityId,
          orElse: () => AppServices.opportunities.allOpportunities.first,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Banner
          SliverAppBar(
            expandedHeight: 190.0,
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                onPressed: () => _showShareSheet(opp),
              ),
              ValueListenableBuilder(
                valueListenable: AppServices.auth.userNotifier,
                builder: (context, user, _) {
                  final isSaved = user?.savedOpportunityIds.contains(opp.id) ?? false;
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isSaved ? AppColors.primaryBright : AppColors.textPrimary,
                    ),
                    onPressed: () => AppServices.auth.toggleSaveOpportunity(opp.id),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF23164D), Color(0xFF101333)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Ambient Glow Circle
                    Positioned(
                      top: -40,
                      right: 20,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryDark.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    // Banner Content Overlay
                    Positioned(
                      bottom: 24,
                      left: 20,
                      child: _buildOrgLogo(opp.organization),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    opp.title,
                    style: AppTextStyles.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Organization
                  Text(
                    opp.organization,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.softLavender,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tags Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDetailBadge(opp.mode),
                      _buildDetailBadge(
                        opp.category == 'Hackathons'
                            ? 'Team Event'
                            : (opp.category == 'Internships' ? 'Internship' : opp.category),
                      ),
                      _buildDetailBadge(
                        opp.salary ?? opp.prize,
                        isHighlight: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons Row: Save, Share, Visit Website
                  Row(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: AppServices.auth.userNotifier,
                        builder: (context, user, _) {
                          final isSaved = user?.savedOpportunityIds.contains(opp.id) ?? false;
                          return _buildActionIconButton(
                            icon: isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            label: isSaved ? 'Saved' : 'Save',
                            color: isSaved ? const Color(0xFFEF4444) : AppColors.textMuted,
                            onTap: () => AppServices.auth.toggleSaveOpportunity(opp.id),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionIconButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        color: AppColors.softLavender,
                        onTap: () => _showShareSheet(opp),
                      ),
                      const SizedBox(width: 12),
                      _buildActionIconButton(
                        icon: Icons.language_rounded,
                        label: 'Visit Website',
                        color: AppColors.cyanHighlight,
                        onTap: () async {
                          final uri = Uri.tryParse(opp.registrationUrl);
                          if (uri != null) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Segmented Tabs: Details, Eligibility, Timeline, More
                  TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorColor: AppColors.primaryBright,
                    indicatorWeight: 3,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                    unselectedLabelStyle: AppTextStyles.labelMedium,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Tab Content Section
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      switch (_tabController.index) {
                        case 0:
                          return _buildDetailsTab(opp);
                        case 1:
                          return _buildEligibilityTab(opp);
                        case 2:
                          return _buildTimelineTab(opp);
                        case 3:
                        default:
                          return _buildMoreTab(opp);
                      }
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed Sticky Apply Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: AppButton(
            text: 'Apply Now ↗',
            onPressed: () => _handleApply(opp),
            variant: AppButtonVariant.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBadge(String label, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight ? AppColors.primaryBright.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isHighlight ? AppColors.primaryLight : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(Opportunity opp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        Text(
          opp.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          maxLines: _isDescriptionExpanded ? 20 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (opp.description.length > 120) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(
              _isDescriptionExpanded ? 'Show less' : 'Show more',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.softLavender,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Text('Skills & Technologies', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opp.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(skill, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEligibilityTab(Opportunity opp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: AppColors.primaryBright, size: 20),
              const SizedBox(width: 8),
              Text('Who Can Apply', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(opp.eligibility, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(Opportunity opp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text('Application Deadline', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Closing Date: ${opp.deadline}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${opp.daysLeft} days remaining to submit your application.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTab(Opportunity opp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verified Source', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Verified from ${opp.source}. Applications submitted through direct partner portal.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
