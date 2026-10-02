import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/report_dialog.dart';
import '../../../data/models/post.dart';
import '../screens/post_detail_screen.dart';
import '../../profile/screens/public_profile_screen.dart';

/// Reusable interactive community Post Card with Riko styling.
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  Color _getCategoryColor(PostType type) {
    switch (type) {
      case PostType.knowledge:
        return AppColors.primaryBright;
      case PostType.question:
        return AppColors.secondaryLight;
      case PostType.project:
        return const Color(0xFFC084FC); // Purple
      case PostType.resource:
        return AppColors.warning;
      case PostType.opportunity:
        return AppColors.cyanHighlight;
      case PostType.discussion:
        return AppColors.softLavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = AppServices.auth.currentUser?.id ?? 'demo_user_1';
    final isLiked = post.isLikedBy(currentUserId);

    return ValueListenableBuilder(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        final isSaved = user?.savedPostIds.contains(post.id) ?? false;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(postId: post.id),
                ),
              );
            },
            borderRadius: AppRadii.cardRadius,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: AppRadii.cardRadius,
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
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
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            post.authorAvatar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
                              Text(
                                post.authorName,
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${post.authorRole} · ${post.timeAgo}',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(post.type).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getCategoryColor(post.type).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          post.type.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _getCategoryColor(post.type),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                        padding: EdgeInsets.zero,
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceElevated,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) async {
                          if (value == 'report') {
                            showReportBottomSheet(
                              context,
                              targetType: 'post',
                              targetId: post.id,
                              targetTitle: post.title,
                            );
                          } else if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
                                title: Text(
                                  'Delete Post?',
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this post? This action cannot be undone.',
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await AppServices.community.deletePost(post.id);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 16,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Report Post',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (post.authorId == currentUserId)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete Post', style: TextStyle(color: AppColors.error, fontSize: 13)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    post.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Content snippet
                  Text(
                    post.content,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.5,
                    ),
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
                          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                        ),
                        child: Text(
                          '#$t',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? const Color(0xFFC084FC) : AppColors.softLavender,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),
                  Divider(color: isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                  const SizedBox(height: 8),

                  // Interaction Row (Upvote, Comment, Bookmark, Share)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Upvote Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                AppServices.community.toggleLikePost(post.id, currentUserId);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isLiked
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isLiked ? AppColors.primaryBright : (isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
                                      size: 16,
                                      color: isLiked ? AppColors.primaryBright : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.upvotes}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isLiked ? AppColors.primaryBright : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

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
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 15,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${post.commentsCount}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                              color: isSaved ? AppColors.primaryBright : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                            ),
                            onPressed: () async {
                              final saved = await AppServices.auth.toggleSavePost(post.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(saved ? 'Post saved to your library' : 'Post removed from saved'),
                                    duration: const Duration(milliseconds: 900),
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
                            icon: Icon(
                              Icons.share_outlined,
                              size: 19,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post link copied to clipboard!'),
                                  duration: Duration(milliseconds: 900),
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
          ),
        );
      },
    );
  }
}
