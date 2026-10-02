import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/mentor.dart';
import '../../mentors/screens/mentor_detail_screen.dart';

/// Reusable interactive Mentor card with Riko styling.
class MentorCard extends StatelessWidget {
  final Mentor mentor;

  const MentorCard({
    super.key,
    required this.mentor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        final isConnected = user?.connectedUserIds.contains(mentor.id) ?? false;
        final isRequested = user?.requestedMentorIds.contains(mentor.id) ?? false;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MentorDetailScreen(mentorId: mentor.id),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          mentor.name.isNotEmpty ? mentor.name[0] : 'M',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    mentor.name,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    mentor.badge,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mentor.role,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.primaryLight : AppColors.softLavender,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mentor.college,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Topics Wrap
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: mentor.skills.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                        ),
                        child: Text(
                          t,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Action Buttons Row (Learn & Connect)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MentorDetailScreen(mentorId: mentor.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.school_outlined, size: 16),
                          label: Text(
                            isRequested ? 'Requested' : 'Learn',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isRequested
                                  ? AppColors.softLavender
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                            backgroundColor: isRequested
                                ? (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
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
                          icon: Icon(isConnected ? Icons.check_rounded : Icons.person_add_outlined, size: 16),
                          label: Text(
                            isConnected ? 'Connected' : 'Connect',
                            style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
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
