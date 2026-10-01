import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/person.dart';
import '../../profile/screens/public_profile_screen.dart';

/// Reusable interactive Person/Student card with Riko styling.
class PersonCard extends StatelessWidget {
  final Person person;

  const PersonCard({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        final isConnected = user?.connectedUserIds.contains(person.id) ?? false;
        final isPending = user?.pendingConnectionIds.contains(person.id) ?? false;

        String buttonText = 'Connect';
        Color btnBg = AppColors.primary;
        Color btnFg = Colors.white;

        if (isConnected) {
          buttonText = 'Connected ✓';
          btnBg = AppColors.surfaceSecondary;
          btnFg = AppColors.softLavender;
        } else if (isPending) {
          buttonText = 'Pending';
          btnBg = AppColors.surfaceElevated;
          btnFg = AppColors.textMuted;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(personId: person.id),
                ),
              );
            },
            borderRadius: AppRadii.cardRadius,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.cardRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          person.avatarInitials,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person.name, style: AppTextStyles.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              person.role,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.softLavender,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${person.college} · ${person.year}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final res = await AppServices.auth.toggleConnectUser(person.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  res == 'Pending'
                                      ? 'Connection request sent to ${person.name}'
                                      : res == 'Connected'
                                          ? 'Connected with ${person.name}!'
                                          : 'Disconnected from ${person.name}',
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.surfaceElevated,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnBg,
                          foregroundColor: btnFg,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(buttonText, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Skills Wrap
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: person.skills.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          s,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '👥 ${person.mutualCount} mutual connections & matching interests',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
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
