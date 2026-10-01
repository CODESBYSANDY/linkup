import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/post.dart';
import '../screens/post_detail_screen.dart';
import '../../profile/screens/public_profile_screen.dart';

/// Reusable interactive community Post Card.
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  Color _getCategoryColor(PostType type) {
    switch (type) {
      case PostType.knowledge:
        return AppColors.primaryDark;
      case PostType.question:
        return AppColors.secondary;
      case PostType.project:
        return const Color(0xFF7C3AED); // Violet
      case PostType.resource:
        return AppColors.warning;
      case PostType.opportunity:
        return AppColors.primary;
      case PostType.discussion:
        return const Color(0xFF0284C7); // Sky
    }
  }

  Color _getCategoryBg(PostType type) {
    switch (type) {
      case PostType.knowledge:
        return AppColors.softTeal;
      case PostType.question:
        return AppColors.softBlue;
      case PostType.project:
        return const Color(0xFFF5F3FF);
      case PostType.resource:
        return AppColors.warningSoft;
      case PostType.opportunity:
        return AppColors.softTeal;
      case PostType.discussion:
        return AppColors.infoSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AppServices.auth.currentUser?.id ?? 'demo_user_1';
    final isLiked = post.isLikedBy(currentUserId);

    return ValueListenableBuilder(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        final isSaved = user?.savedPostIds.contains(post.id) ?? false;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: post.id),
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
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author & Category Header
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
                        radius: 18,
                        backgroundColor: AppColors.softTeal,
                        child: Text(
                          post.authorAvatar,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                            Text(post.authorName, style: AppTextStyles.titleSmall),
                            Text(
                              '${post.authorRole} · ${post.timeAgo}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryBg(post.type),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.type.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getCategoryColor(post.type),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(post.title, style: AppTextStyles.titleMedium),

                const SizedBox(height: 6),

                // Content snippet
                Text(
                  post.content,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: post.tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$t',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),

                // Interaction Row (Upvote, Comment, Bookmark, Share)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Upvote Button
                        InkWell(
                          onTap: () {
                            AppServices.community.toggleLikePost(post.id, currentUserId);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
                                  size: 18,
                                  color: isLiked ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.likesCount}',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isLiked ? AppColors.primaryDark : AppColors.textSecondary,
                                    fontWeight: isLiked ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Comment count button
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PostDetailScreen(postId: post.id),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.commentsCount}',
                                  style: AppTextStyles.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        // Bookmark button
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 20,
                            color: isSaved ? AppColors.primary : AppColors.textSecondary,
                          ),
                          onPressed: () async {
                            final saved = await AppServices.auth.toggleSavePost(post.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(saved ? 'Post saved to your library' : 'Post removed from saved'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tooltip: 'Save Post',
                        ),

                        // Share button
                        IconButton(
                          icon: const Icon(
                            Icons.share_outlined,
                            size: 19,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post link copied to clipboard!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tooltip: 'Share Post',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
