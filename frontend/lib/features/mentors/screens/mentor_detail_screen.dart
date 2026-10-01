import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';

/// Screen displaying mentor profile, guidance topics, and learning sessions.
class MentorDetailScreen extends StatelessWidget {
  final String mentorId;

  const MentorDetailScreen({
    super.key,
    required this.mentorId,
  });

  @override
  Widget build(BuildContext context) {
    final mentor = AppServices.connect.getMentorById(mentorId);

    if (mentor == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Mentor not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mentor Profile'),
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
              final isRequested = user?.requestedMentorIds.contains(mentor.id) ?? false;
              final isConnected = user?.connectedUserIds.contains(mentor.id) ?? false;

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final res = await AppServices.auth.toggleConnectUser(mentor.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res == 'Pending' ? 'Connection request sent' : 'Connected!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: Icon(isConnected ? Icons.check_rounded : Icons.person_add_outlined, size: 18),
                      label: Text(isConnected ? 'Connected' : 'Connect'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final req = await AppServices.auth.requestMentor(mentor.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(req ? 'Mentorship session requested!' : 'Request cancelled'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: req ? AppColors.success : AppColors.textPrimary,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.school_rounded, size: 18),
                      label: Text(isRequested ? 'Requested' : 'Request to Learn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRequested ? AppColors.softTeal : AppColors.primary,
                        foregroundColor: isRequested ? AppColors.primaryDark : AppColors.textInverse,
                      ),
                    ),
                  ),
                ],
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
              // Mentor Profile Card
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
                      backgroundColor: AppColors.softTeal,
                      child: Text(
                        mentor.name.isNotEmpty ? mentor.name[0] : 'M',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(mentor.name, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 4),
                    Text(mentor.role, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(mentor.college, style: AppTextStyles.caption),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mentor.badge,
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      mentor.about,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mentorship Topics
              const Text('Areas of Guidance', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mentor.topics.map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(topic, style: AppTextStyles.labelMedium),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Learning Sessions List
              const Text('Structured Learning Modules', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              ...mentor.sessions.map((sess) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.play_lesson_rounded, size: 20, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sess.title, style: AppTextStyles.titleSmall),
                              const SizedBox(height: 4),
                              Text(sess.description, style: AppTextStyles.bodySmall),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.textTertiary),
                                  const SizedBox(width: 4),
                                  Text(sess.duration, style: AppTextStyles.caption),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
