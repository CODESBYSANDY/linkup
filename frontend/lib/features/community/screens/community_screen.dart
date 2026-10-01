import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import '../../home/screens/search_screen.dart';

/// Interactive Community & Knowledge sharing feed.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

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
    '💬 Discussions',
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
      case '💬 Discussions':
        return PostType.discussion;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community & Knowledge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
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
                  color: _showOnlySaved ? AppColors.primary : AppColors.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _showOnlySaved = !_showOnlySaved;
                  });
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_showOnlySaved ? 'Showing saved posts ($savedCount)' : 'Showing all community posts'),
                      duration: const Duration(seconds: 1),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('New Post', style: AppTextStyles.labelLarge),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: AppColors.background,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = _selectedFilter == f && !_showOnlySaved;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = f;
                            _showOnlySaved = false;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: isSelected ? AppColors.textPrimary : AppColors.border,
                        ),
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const Divider(height: 1),

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
                    return EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: _showOnlySaved ? 'No saved discussions' : 'No posts in this category yet',
                      description: _showOnlySaved
                          ? 'Bookmark useful discussions to revisit them here anytime.'
                          : 'Be the first student to share your question or insight with the community!',
                      actionLabel: 'Create Post',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: displayPosts.length + 1, // +1 for extra bottom padding for FAB
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == displayPosts.length) {
                        return const SizedBox(height: 70); // FAB clear
                      }
                      return PostCard(post: displayPosts[index]);
                    },
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
