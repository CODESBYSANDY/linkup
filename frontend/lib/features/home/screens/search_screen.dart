import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/person.dart';
import '../../../data/models/group.dart';
import '../../../data/models/post.dart';
import '../../opportunities/widgets/opportunity_card.dart';
import '../../profile/screens/public_profile_screen.dart';
import '../../groups/screens/group_detail_screen.dart';
import '../../community/screens/post_detail_screen.dart';

/// Screen performing search across Opportunities, People, Groups, and Posts.
class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Opportunities', 'People', 'Groups', 'Posts'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.softTeal,
                child: Text(
                  person.avatarInitials,
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name, style: AppTextStyles.titleSmall),
                    Text(person.role, style: AppTextStyles.caption),
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: AppTextStyles.titleSmall),
                    Text('${group.membersCount} members · ${group.category}', style: AppTextStyles.caption),
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title, style: AppTextStyles.titleSmall),
              const SizedBox(height: 4),
              Text(
                post.content,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'By ${post.authorName} · ${post.commentsCount} comments · ${post.likesCount} upvotes',
                style: AppTextStyles.caption,
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
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search hackathons, people, topics...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      child: ChoiceChip(
                        label: Text(_filters[index]),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedFilterIndex = index),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.softTeal,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const Divider(height: 1),

            // Search Content
            Expanded(
              child: !hasAnyResults
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No results found',
                      description: 'Try searching with different keywords like "Cybersecurity", "AI", "Internship", or "Python".',
                      actionLabel: 'Clear Search',
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
