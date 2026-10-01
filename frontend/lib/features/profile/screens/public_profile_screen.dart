import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../community/widgets/post_card.dart';

/// Screen displaying a public student profile with Riko styling.
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
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Student Profile',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
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
              Color btnFg = Colors.white;

              if (isConnected) {
                btnText = 'Connected ✓';
                btnBg = AppColors.surfaceSecondary;
                btnFg = AppColors.softLavender;
              } else if (isPending) {
                btnText = 'Request Pending';
                btnBg = AppColors.surfaceElevated;
                btnFg = AppColors.textMuted;
              }

              return ElevatedButton(
                onPressed: () async {
                  final res = await AppServices.auth.toggleConnectUser(personId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res == 'Pending' ? 'Connection request sent' : res == 'Connected' ? 'Connected!' : 'Disconnected'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.surfaceElevated,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnBg,
                  foregroundColor: btnFg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(btnText, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
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
                  borderRadius: AppRadii.cardRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name.isNotEmpty ? name[0] : 'S',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(role, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softLavender, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('$college · $year', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 12),
                    Text(bio, textAlign: TextAlign.center, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Skills Section
              const Text('Skills & Expertise', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(s, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Interests Section
              const Text('Technical Interests', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.3)),
                    ),
                    child: Text(i, style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
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
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          'No public posts yet.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
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
