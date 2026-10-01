import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
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
    await Future.delayed(const Duration(milliseconds: 300)); // UI smoothness

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
        title: Text(widget.initialGroupName != null ? 'Post in ${widget.initialGroupName}' : 'Create Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _handlePublish,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Publish', style: AppTextStyles.labelMedium),
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
                const Text('Choose Category', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: PostType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type.displayName),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedType = type),
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
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Title Field
                Text('Title', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
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
                Text('Content / Explanation', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
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
                Text('Tags (comma separated)', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Cybersecurity, Wireshark, Linux, CTF',
                    prefixIcon: Icon(Icons.tag_rounded, size: 20),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
