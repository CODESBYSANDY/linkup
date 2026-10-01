import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../data/models/person.dart';
import '../../../data/models/group.dart';
import '../../../data/models/post.dart';
import '../../opportunities/widgets/opportunity_card.dart';
import '../../profile/screens/public_profile_screen.dart';
import '../../groups/screens/group_detail_screen.dart';
import '../../community/screens/post_detail_screen.dart';

/// Comprehensive search screen across Opportunities, People, Groups, and Posts.
class SearchScreen extends StatefulWidget {
  final String initialQuery;
  final String? initialCategory;

  const SearchScreen({
    super.key,
    this.initialQuery = '',
    this.initialCategory,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Opportunities', 'People', 'Communities', 'Posts'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialCategory != null) {
      _selectedFilterIndex = 1; // Filter to opportunities
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildPersonTile(Person person) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PublicProfileScreen(personId: person.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                radius: 22,
                child: Text(
                  person.avatarInitials,
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryLight),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      person.role,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile(Group group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => GroupDetailScreen(groupId: group.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.secondaryLight, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${group.membersCount} members · ${group.category}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTile(Post post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PostDetailScreen(postId: post.id),
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 6),
              Text(
                post.content,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                'By ${post.authorName} · ${post.commentsCount} comments · ${post.upvotes} upvotes',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final matchedOpportunities = AppServices.opportunities.filterOpportunities(query: query);
    final matchedPeople = AppServices.connect.allPeople.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.role.toLowerCase().contains(query) ||
          p.college.toLowerCase().contains(query) ||
          p.skills.any((s) => s.toLowerCase().contains(query));
    }).toList();

    final matchedGroups = AppServices.connect.allGroups.where((g) {
      if (query.isEmpty) return true;
      return g.name.toLowerCase().contains(query) ||
          g.category.toLowerCase().contains(query) ||
          g.description.toLowerCase().contains(query);
    }).toList();

    final matchedPosts = AppServices.community.filterPosts(query: query);

    final bool hasAnyResults = matchedOpportunities.isNotEmpty ||
        matchedPeople.isNotEmpty ||
        matchedGroups.isNotEmpty ||
        matchedPosts.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search hackathons, people, topics...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.softLavender),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: AppColors.background,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: _filters[index],
                        isSelected: isSelected,
                        onSelected: () => setState(() => _selectedFilterIndex = index),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const Divider(height: 1, color: AppColors.borderSubtle),

            // Search Content
            Expanded(
              child: !hasAnyResults
                  ? RikoEmptyState(
                      expression: RikoExpression.thinking,
                      title: 'No results found',
                      message: 'Riko could not find anything matching "$query". Try searching with keywords like "Cybersecurity", "AI", "Hackathon", or "Python".',
                      actionLabel: 'Clear Search',
                      actionIcon: Icons.refresh_rounded,
                      onAction: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      children: [
                        // Opportunities Section
                        if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 1) &&
                            matchedOpportunities.isNotEmpty) ...[
                          Text('Opportunities (${matchedOpportunities.length})', style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 12),
                          ...matchedOpportunities.take(_selectedFilterIndex == 1 ? 50 : 3).map((opp) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OpportunityCard(opportunity: opp),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],

                        // People Section
                        if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 2) &&
                            matchedPeople.isNotEmpty) ...[
                          Text('People (${matchedPeople.length})', style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 12),
                          ...matchedPeople.take(_selectedFilterIndex == 2 ? 50 : 3).map(_buildPersonTile),
                          const SizedBox(height: 16),
                        ],

                        // Groups Section
                        if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 3) &&
                            matchedGroups.isNotEmpty) ...[
                          Text('Communities (${matchedGroups.length})', style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 12),
                          ...matchedGroups.take(_selectedFilterIndex == 3 ? 50 : 3).map(_buildGroupTile),
                          const SizedBox(height: 16),
                        ],

                        // Posts Section
                        if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 4) &&
                            matchedPosts.isNotEmpty) ...[
                          Text('Discussions (${matchedPosts.length})', style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 12),
                          ...matchedPosts.take(_selectedFilterIndex == 4 ? 50 : 3).map(_buildPostTile),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
