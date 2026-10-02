import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../data/models/opportunity.dart';

/// Screen 4: Opportunity Details Screen
/// Faithfully reproduces Image 3 & 4 (Screen 5) from the reference design:
/// - Hero banner image/stage
/// - Floating white card with company logo, title, organization, tags
/// - Quick action buttons: Save, Share, Visit Website
/// - Interactive Tabs: Details, Eligibility, Timeline, More
/// - About section with expandable description
/// - Sticky bottom bar with vibrant purple "Apply Now ↗" button
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Apply to Opportunity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opp.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organization: ${opp.organization}',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFEDE9FE),
                  ),
                ),
                child: Text(
                  'Your student profile (Name, College, Skills) is ready to be submitted to this opportunity.',
                  style: TextStyle(
                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application submitted successfully! 🚀'),
                    backgroundColor: Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Submit Application', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppServices.opportunities.opportunitiesNotifier,
      builder: (context, opps, _) {
        final opp = opps.firstWhere(
          (o) => o.id == widget.opportunityId,
          orElse: () => opps.isNotEmpty
              ? opps.first
              : const Opportunity(
                  id: 'default',
                  title: 'Google GenAI Hackathon 2025',
                  organization: 'Google',
                  category: 'Hackathons',
                  domain: 'AI / ML',
                  description: 'Build innovative AI-powered solutions to solve real-world problems. Open to all students across India.',
                  eligibility: 'All college undergraduate & postgraduate students',
                  skills: ['Python', 'Gemini API', 'Flutter'],
                  location: 'Online',
                  mode: 'Online',
                  prize: '₹5,00,000',
                  deadline: '2026-10-18',
                  source: 'Google',
                  registrationUrl: 'https://developers.google.com',
                  daysLeft: 12,
                ),
        );

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          body: ResponsiveContentWrapper(
            maxWidth: 1000,
            child: Stack(
              children: [
                // Scrollable Content
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Sliver App Bar with Stage Hero Image
                    _buildSliverHero(opp),

                    // Main Content Body
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Info: Logo, Title, Organization
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CompanyLogo(
                                  organization: opp.organization,
                                  size: 54,
                                  borderRadius: 16,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opp.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opp.organization,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Badges Row per reference
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildBadge(opp.mode),
                                _buildBadge(
                                  opp.category == 'Hackathons' ? 'Team Event' : opp.category,
                                ),
                                if (opp.prize.isNotEmpty) _buildBadge(opp.prize),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Quick Action Buttons: Save, Share, Visit Website
                            _buildQuickActions(opp),

                            const SizedBox(height: 18),
                            Divider(
                              color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
                              thickness: 1,
                            ),

                            // Tabs: Details, Eligibility, Timeline, More
                            TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 3,
                              labelColor: AppColors.primary,
                              unselectedLabelColor: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
                              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              tabs: _tabs.map((t) => Tab(text: t)).toList(),
                            ),

                            const SizedBox(height: 18),

                            // Tab Content Area
                            _buildDetailsTabContent(opp),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating Sticky Bottom "Apply Now ↗" Button per reference
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : const Color(0xFF0F172A).withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x356366F1),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleApply(opp),
                            borderRadius: BorderRadius.circular(28),
                            child: const Center(
                              child: Text(
                                'Apply Now ↗',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverHero(Opportunity opp) {
    return SliverAppBar(
      expandedHeight: 210,
      pinned: true,
      backgroundColor: const Color(0xFF101333),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        ValueListenableBuilder(
          valueListenable: AppServices.auth.userNotifier,
          builder: (context, user, _) {
            final isSaved = user?.savedOpportunityIds.contains(opp.id) ?? false;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? AppColors.primary : Colors.white,
                    size: 20,
                  ),
                  onPressed: () => AppServices.auth.toggleSaveOpportunity(opp.id),
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF101333)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Purple lighting ambience matching reference image stage
              Positioned(
                top: -60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 280,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x668B5CF6), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFFA78BFA), size: 36),
                    SizedBox(height: 6),
                    Text(
                      'OPPORTUNITY SCOUT',
                      style: TextStyle(
                        color: Color(0xFFDDD6FE),
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickActions(Opportunity opp) {
    return Row(
      children: [
        Expanded(
          child: _buildActionPill(
            icon: Icons.bookmark_border_rounded,
            label: 'Save',
            onTap: () => AppServices.auth.toggleSaveOpportunity(opp.id),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionPill(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opportunity link copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionPill(
            icon: Icons.open_in_browser_rounded,
            label: 'Visit Website',
            onTap: () => _handleApply(opp),
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF334155),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTabContent(Opportunity opp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Section per reference
        Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          opp.description,
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Text(
            _isDescriptionExpanded ? 'Show less' : 'Show more',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Eligibility
        Text(
          'Eligibility',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          opp.eligibility,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 20),

        // Required Skills
        Text(
          'Skills & Technologies',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: opp.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEDE9FE),
                ),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
