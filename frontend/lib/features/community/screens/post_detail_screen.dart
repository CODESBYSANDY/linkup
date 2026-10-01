import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/post.dart';
import '../../../data/models/comment.dart';
import '../../profile/screens/public_profile_screen.dart';

/// Screen displaying complete details for a community discussion with interactive comments.
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleAddComment(Post post) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = AppServices.auth.currentUser;
    final newComment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      authorName: user?.name ?? 'Sandeep B',
      authorRole: user?.branch.isNotEmpty == true ? '${user?.year} · ${user?.branch}' : 'Year 3 · Student Developer',
      authorAvatar: user?.avatarInitials ?? 'SB',
      content: text,
      timeAgo: 'Just now',
    );

    AppServices.community.addComment(post.id, newComment);
    _commentController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment published!'),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AppServices.auth.currentUser?.id ?? 'demo_user_1';

    return ValueListenableBuilder(
      valueListenable: AppServices.community.postsNotifier,
      builder: (context, posts, _) {
        final post = AppServices.community.getById(widget.postId);

        if (post == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Discussion not found')),
          );
        }

        final isLiked = post.isLikedBy(currentUserId);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Discussion'),
            actions: [
              ValueListenableBuilder(
                valueListenable: AppServices.auth.userNotifier,
                builder: (context, user, _) {
                  final isSaved = user?.savedPostIds.contains(post.id) ?? false;
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isSaved ? AppColors.primary : AppColors.textPrimary,
                    ),
                    onPressed: () async {
                      final saved = await AppServices.auth.toggleSavePost(post.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(saved ? 'Post saved to library' : 'Removed from saved'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post link copied to clipboard!')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add an answer or comment...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: () => _handleAddComment(post),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverse,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Post Main Container
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
                      // Author Row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PublicProfileScreen(
                                    personId: post.authorId,
                                    fallbackName: post.authorName,
                                    fallbackRole: post.authorRole,
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.softTeal,
                              child: Text(
                                post.authorAvatar,
                                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PublicProfileScreen(
                                      personId: post.authorId,
                                      fallbackName: post.authorName,
                                      fallbackRole: post.authorRole,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.authorName, style: AppTextStyles.titleMedium),
                                  Text('${post.authorRole} · ${post.timeAgo}', style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softTeal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              post.type.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(post.title, style: AppTextStyles.headlineSmall),

                      const SizedBox(height: 12),

                      // Content Body
                      Text(
                        post.content,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                      ),

                      const SizedBox(height: 16),

                      // Tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: post.tags.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('#$t', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              AppServices.community.toggleLikePost(post.id, currentUserId);
                            },
                            icon: Icon(
                              isLiked ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
                              size: 18,
                            ),
                            label: Text(
                              isLiked ? 'Upvoted (${post.likesCount})' : 'Upvote (${post.likesCount})',
                              style: AppTextStyles.labelMedium,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLiked ? AppColors.primary : AppColors.surfaceSubtle,
                              foregroundColor: isLiked ? AppColors.textInverse : AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                          Text(
                            '${post.commentsCount} Comments',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Comments Section Header
                const Text('Discussion & Answers', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),

                // Comments List
                if (post.comments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textTertiary, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'No answers or comments yet.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Be the first to share your knowledge!',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...post.comments.map((comment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.softBlue,
                                  child: Text(
                                    comment.authorAvatar,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(comment.authorName, style: AppTextStyles.titleSmall),
                                      Text('${comment.authorRole} · ${comment.timeAgo}', style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(comment.content, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
