import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../data/models/post.dart';

/// Screen allowing students to compose and publish new community posts.
class CreatePostScreen extends StatefulWidget {
  final String? initialGroupId;
  final String? initialGroupName;

  const CreatePostScreen({
    super.key,
    this.initialGroupId,
    this.initialGroupName,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController(text: 'Cybersecurity, AI, Flutter');
  PostType _selectedType = PostType.knowledge;
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final user = AppServices.auth.currentUser;
    final tagsList = _tagsController.text
        .split(',')
        .map((t) => t.trim().replaceAll('#', ''))
        .where((t) => t.isNotEmpty)
        .toList();

    final newPost = Post(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: user?.id ?? 'demo_user_1',
      authorName: user?.name.isNotEmpty == true ? user!.name : 'Sandeep B',
      authorRole: user?.branch.isNotEmpty == true ? '${user?.year} · ${user?.branch}' : 'Year 3 · Student Developer',
      authorYear: user?.year ?? 'Year 3',
      authorAvatar: user?.avatarInitials ?? 'SB',
      type: _selectedType,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tags: tagsList.isNotEmpty ? tagsList : ['Knowledge', 'Tech'],
      likedUserIds: [],
      comments: [],
      timeAgo: 'Just now',
      groupId: widget.initialGroupId,
      groupName: widget.initialGroupName,
    );

    AppServices.community.addPost(newPost);
    if (!mounted) return;
    setState(() => _isPublishing = false);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post published to student community! 🎉'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          widget.initialGroupName != null ? 'Post in ${widget.initialGroupName}' : 'Create Post',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _handlePublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isPublishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Publish', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Type Selector
                const Text('Choose Category', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: PostType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppChip(
                          label: type.displayName,
                          isSelected: isSelected,
                          onSelected: () => setState(() => _selectedType = type),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Title Field
                Text('Title', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. How to set up Wireshark for local packet sniffing?',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Content Field
                Text('Content / Explanation', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Share your question details, technical tutorial, project repo link, or learning insight...',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please write some content';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Tags Field
                Text('Tags (comma separated)', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tagsController,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Cybersecurity, Wireshark, Linux, CTF',
                    prefixIcon: Icon(Icons.tag_rounded, size: 20),
                  ),
                ),

                const SizedBox(height: 28),

                AppButton(
                  text: 'Publish Post',
                  onPressed: _handlePublish,
                  isLoading: _isPublishing,
                  variant: AppButtonVariant.primary,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
