import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../community/widgets/post_card.dart';

/// Screen displaying a public student profile.
class PublicProfileScreen extends StatelessWidget {
  final String personId;
  final String? fallbackName;
  final String? fallbackRole;

  const PublicProfileScreen({
    super.key,
    required this.personId,
    this.fallbackName,
    this.fallbackRole,
  });

  @override
  Widget build(BuildContext context) {
    final person = AppServices.connect.getPersonById(personId);

    final name = person?.name ?? fallbackName ?? 'Student Developer';
    final role = person?.role ?? fallbackRole ?? 'Computer Science Student';
    final college = person?.college ?? 'Engineering Institution';
    final year = person?.year ?? 'Year 3';
    final bio = person?.bio ?? 'Active tech enthusiast exploring open source, software engineering, and student communities.';
    final skills = person?.skills ?? ['Computer Science', 'Software Development', 'Python'];
    final interests = person?.interests ?? ['🛡️ Cybersecurity', '🤖 AI / ML', '🏆 Hackathons'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: AppServices.auth.userNotifier,
            builder: (context, user, _) {
              final isConnected = user?.connectedUserIds.contains(personId) ?? false;
              final isPending = user?.pendingConnectionIds.contains(personId) ?? false;

              String btnText = 'Connect';
              Color btnBg = AppColors.primary;
              Color btnFg = AppColors.textInverse;

              if (isConnected) {
                btnText = 'Connected';
                btnBg = AppColors.softTeal;
                btnFg = AppColors.primaryDark;
              } else if (isPending) {
                btnText = 'Request Pending';
                btnBg = AppColors.surfaceSubtle;
                btnFg = AppColors.textSecondary;
              }

              return ElevatedButton(
                onPressed: () async {
                  final res = await AppServices.auth.toggleConnectUser(personId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res == 'Pending' ? 'Connection request sent' : res == 'Connected' ? 'Connected!' : 'Disconnected'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnBg,
                  foregroundColor: btnFg,
                ),
                child: Text(btnText, style: AppTextStyles.labelLarge),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.softBlue,
                      child: Text(
                        name.isNotEmpty ? name[0] : 'S',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 4),
                    Text(role, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('$college · $year', style: AppTextStyles.caption),
                    const SizedBox(height: 12),
                    Text(bio, textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Skills Section
              const Text('Skills & Expertise', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(s, style: AppTextStyles.labelMedium),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Interests Section
              const Text('Technical Interests', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.softTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(i, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Activity & Discussions by this user
              Text('Posts by $name', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),

              ValueListenableBuilder(
                valueListenable: AppServices.community.postsNotifier,
                builder: (context, posts, _) {
                  final userPosts = posts.where((p) => p.authorId == personId || p.authorName.toLowerCase() == name.toLowerCase()).toList();

                  if (userPosts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          'No public posts yet.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: userPosts.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PostCard(post: p),
                    )).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
