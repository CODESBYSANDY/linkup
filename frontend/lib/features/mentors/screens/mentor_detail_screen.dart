import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_background.dart';

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
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text('Mentor not found', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mentor Profile', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
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
                              backgroundColor: AppColors.surfaceElevated,
                              content: Text(
                                res == 'Pending' ? 'Connection request sent' : 'Connected!',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        isConnected ? Icons.check_rounded : Icons.person_add_outlined,
                        size: 18,
                      ),
                      label: Text(isConnected ? 'Connected' : 'Connect'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isConnected ? AppColors.lavender : AppColors.textPrimary,
                        side: BorderSide(
                          color: isConnected ? AppColors.primaryBright : AppColors.cardBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isRequested ? null : AppShadows.purpleGlow,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final req = await AppServices.auth.requestMentor(mentor.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: req ? AppColors.primaryBright : AppColors.surfaceElevated,
                                content: Text(
                                  req ? 'Mentorship session requested!' : 'Request cancelled',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.school_rounded, size: 18),
                        label: Text(isRequested ? 'Requested' : 'Request Session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRequested ? AppColors.surfaceElevated : AppColors.primaryBright,
                          foregroundColor: isRequested ? AppColors.lavender : AppColors.textInverse,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: AppBackground(
        showGlows: true,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mentor Profile Hero Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: AppShadows.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.purpleGradient,
                          boxShadow: AppShadows.purpleGlow,
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.surface,
                          child: Text(
                            mentor.name.isNotEmpty ? mentor.name[0] : 'M',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lavender,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        mentor.name,
                        style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor.role,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.lavender,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mentor.college,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, size: 14, color: AppColors.electricBlue),
                            const SizedBox(width: 4),
                            Text(
                              mentor.badge,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        mentor.about,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Mentorship Topics
                const Text('Areas of Guidance', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mentor.topics.map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primaryBright),
                          const SizedBox(width: 8),
                          Text(
                            topic,
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Learning Sessions List
                const Text('Structured Learning Modules', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                ...mentor.sessions.map((sess) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.play_lesson_rounded,
                              size: 22,
                              color: AppColors.primaryBright,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sess.title,
                                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sess.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      sess.duration,
                                      style: AppTextStyles.caption.copyWith(color: AppColors.lavender),
                                    ),
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
      ),
    );
  }
}
