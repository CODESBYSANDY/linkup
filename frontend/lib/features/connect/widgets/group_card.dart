import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/group.dart';
import '../../groups/screens/group_detail_screen.dart';

/// Reusable interactive Group card with Riko styling.
class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({
    super.key,
    required this.group,
  });

  IconData _getIconData(String name) {
    switch (name) {
      case 'security':
        return Icons.security_rounded;
      case 'ai':
        return Icons.psychology_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'cloud':
        return Icons.cloud_queue_rounded;
      case 'mobile':
        return Icons.phone_android_rounded;
      case 'hackathon':
        return Icons.emoji_events_rounded;
      default:
        return Icons.groups_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        final isJoined = user?.joinedGroupIds.contains(group.id) ?? false;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(groupId: group.id),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF261A52), Color(0xFF141738)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      _getIconData(group.iconName),
                      color: AppColors.primaryLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final joined = await AppServices.auth.toggleJoinGroup(group.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(joined ? 'Joined ${group.name}' : 'Left ${group.name}'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isJoined
                                    ? (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary)
                                    : AppColors.primary,
                                foregroundColor: isJoined
                                    ? (isDark ? AppColors.primaryLight : AppColors.softLavender)
                                    : Colors.white,
                                side: BorderSide(
                                  color: isJoined ? AppColors.primaryBright.withValues(alpha: 0.4) : Colors.transparent,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                isJoined ? 'Joined ✓' : 'Join',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${group.membersCount} members · ${group.category}',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.primaryLight : AppColors.softLavender,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          group.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
