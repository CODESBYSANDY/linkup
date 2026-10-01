import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../data/models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import '../../home/screens/search_screen.dart';

/// Interactive Community & Knowledge sharing feed.
class CommunityScreen extends StatefulWidget {
  final bool showBackButton;

  const CommunityScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedFilter = 'All Posts';
  bool _showOnlySaved = false;

  final List<String> _filters = [
    'All Posts',
    '💡 Knowledge',
    '❓ Questions',
    '🚀 Projects',
    '📚 Resources',
  ];

  PostType? _mapFilterToType(String filter) {
    switch (filter) {
      case '💡 Knowledge':
        return PostType.knowledge;
      case '❓ Questions':
        return PostType.question;
      case '🚀 Projects':
        return PostType.project;
      case '📚 Resources':
        return PostType.resource;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        title: Text(
          'Community',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            tooltip: 'Search Discussions',
          ),
          ValueListenableBuilder(
            valueListenable: AppServices.auth.userNotifier,
            builder: (context, user, _) {
              final savedCount = user?.savedPostIds.length ?? 0;
              return IconButton(
                icon: Icon(
                  _showOnlySaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: _showOnlySaved ? AppColors.primaryBright : AppColors.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _showOnlySaved = !_showOnlySaved;
                  });
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_showOnlySaved ? 'Showing saved posts ($savedCount)' : 'Showing all community posts'),
                      duration: const Duration(milliseconds: 900),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  );
                },
                tooltip: 'Saved Posts',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          boxShadow: AppShadows.buttonGlow,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.edit_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f && !_showOnlySaved;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: f,
                      isSelected: isSelected,
                      onSelected: () {
                        setState(() {
                          _selectedFilter = f;
                          _showOnlySaved = false;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 1, color: AppColors.borderSubtle),

            // Feed Content
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: AppServices.community.postsNotifier,
                builder: (context, posts, _) {
                  final targetType = _mapFilterToType(_selectedFilter);

                  var displayPosts = posts;

                  if (_showOnlySaved) {
                    final savedIds = AppServices.auth.currentUser?.savedPostIds ?? [];
                    displayPosts = displayPosts.where((p) => savedIds.contains(p.id)).toList();
                  } else if (targetType != null) {
                    displayPosts = displayPosts.where((p) => p.type == targetType).toList();
                  }

                  if (displayPosts.isEmpty) {
                    return RikoEmptyState(
                      expression: RikoExpression.thinking,
                      title: _showOnlySaved ? 'No saved discussions' : 'No posts in this category yet',
                      message: _showOnlySaved
                          ? 'Bookmark useful discussions to revisit them here anytime.'
                          : 'Be the first student to share your question or insight with the community!',
                      actionLabel: 'Create Post',
                      actionIcon: Icons.add_rounded,
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                        );
                      },
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryBright,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async {
                      await AppServices.community.fetchPosts(isRefresh: true);
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: displayPosts.length + 1, // +1 for extra bottom padding for FAB
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        if (index == displayPosts.length) {
                          return const SizedBox(height: 70); // FAB clear
                        }
                        return PostCard(post: displayPosts[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
