import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/report_dialog.dart';
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
      authorName: (user?.name.isNotEmpty == true) ? user!.name : 'Student',
      authorRole: (user?.branch.isNotEmpty == true && user?.year.isNotEmpty == true)
          ? '${user?.year} · ${user?.branch}'
          : 'Student',
      authorAvatar: user?.avatarInitials ?? (user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S'),
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
    final currentUserId = AppServices.auth.currentUser?.id ?? '';

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
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Discussion',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              ValueListenableBuilder(
                valueListenable: AppServices.auth.userNotifier,
                builder: (context, user, _) {
                  final isSaved = user?.savedPostIds.contains(post.id) ?? false;
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isSaved ? AppColors.primaryBright : AppColors.textPrimary,
                    ),
                    onPressed: () async {
                      final saved = await AppServices.auth.toggleSavePost(post.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(saved ? 'Post saved to library' : 'Removed from saved'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.surfaceElevated,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post link copied to clipboard!'),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
                color: AppColors.surfaceElevated,
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
                        backgroundColor: AppColors.surface,
                        title: const Text('Delete Post?'),
                        content: const Text('Are you sure you want to delete this post? This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await AppServices.community.deletePost(post.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text('Report Post', style: AppTextStyles.bodySmall),
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
              const SizedBox(width: 4),
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
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: AppRadii.inputRadius,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Add an answer or comment...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleAddComment(post),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      ),
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
                    borderRadius: AppRadii.cardRadius,
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
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                post.authorAvatar,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                                  Text('${post.authorRole} · ${post.timeAgo}', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              post.type.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryLight,
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
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textSecondary),
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
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text('#$t', style: AppTextStyles.caption.copyWith(color: AppColors.softLavender)),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderSubtle),
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
                              size: 16,
                            ),
                            label: Text(
                              isLiked ? 'Upvoted (${post.upvotes})' : 'Upvote (${post.upvotes})',
                              style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLiked ? AppColors.primary : AppColors.surfaceSecondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                          Text(
                            '${post.commentsCount} Comments',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted),
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
                      borderRadius: AppRadii.cardRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textTertiary, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'No answers or comments yet.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Be the first to share your knowledge!',
                            style: AppTextStyles.caption.copyWith(color: AppColors.softLavender),
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
                          borderRadius: AppRadii.cardRadius,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    comment.authorAvatar,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryLight),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(comment.authorName, style: AppTextStyles.titleSmall),
                                      Text('${comment.authorRole} · ${comment.timeAgo}', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_horiz_rounded, size: 16, color: AppColors.textMuted),
                                  padding: EdgeInsets.zero,
                                  color: AppColors.surfaceElevated,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  onSelected: (val) async {
                                    if (val == 'report') {
                                      showReportBottomSheet(
                                        context,
                                        targetType: 'comment',
                                        targetId: comment.id,
                                        targetTitle: comment.content,
                                      );
                                    } else if (val == 'delete') {
                                      await AppServices.community.deleteComment(post.id, comment.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(Icons.flag_outlined, size: 15, color: AppColors.textSecondary),
                                          SizedBox(width: 6),
                                          Text('Report', style: AppTextStyles.bodySmall),
                                        ],
                                      ),
                                    ),
                                    if (comment.authorName == (AppServices.auth.currentUser?.name ?? ''))
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.error),
                                            SizedBox(width: 6),
                                            Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(comment.content, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
