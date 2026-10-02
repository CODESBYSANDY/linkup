import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../../data/models/notification_item.dart';

/// Screen displaying student activity & Riko Scout notifications.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  RikoExpression _getExpressionForType(NotificationType type) {
    switch (type) {
      case NotificationType.opportunity:
        return RikoExpression.excited;
      case NotificationType.connection:
        return RikoExpression.waving;
      case NotificationType.like:
        return RikoExpression.celebrating;
      case NotificationType.comment:
        return RikoExpression.helpful;
      case NotificationType.mentor:
        return RikoExpression.usingTablet;
      case NotificationType.group:
        return RikoExpression.happy;
      case NotificationType.system:
        return RikoExpression.surprised;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppServices.notifications.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.primaryLight : AppColors.softLavender,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContentWrapper(
          maxWidth: 800,
          child: RefreshIndicator(
            onRefresh: () async {
              await AppServices.notifications.refresh();
            },
            color: AppColors.primaryBright,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
            child: ValueListenableBuilder(
              valueListenable: AppServices.notifications.notificationsNotifier,
              builder: (context, notifs, _) {
                if (notifs.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    children: const [
                      SizedBox(height: 60),
                      RikoEmptyState(
                        expression: RikoExpression.sleeping,
                        title: 'All caught up!',
                        message: 'No new notifications right now. Riko is scouting opportunities in the background.',
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: notifs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = notifs[index];
                    final expression = _getExpressionForType(notif.type);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          AppServices.notifications.markAsRead(notif.id);
                        },
                        borderRadius: AppRadii.cardRadius,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: notif.isRead
                                ? (isDark ? AppColors.darkSurface : AppColors.surface)
                                : (isDark ? const Color(0xFF222659) : const Color(0xFFF3E8FF)),
                            borderRadius: AppRadii.cardRadius,
                            border: Border.all(
                              color: notif.isRead
                                  ? (isDark ? AppColors.darkBorder : AppColors.border)
                                  : AppColors.primaryBright.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RikoAvatar(
                                expression: expression,
                                size: 40,
                                showGlow: !notif.isRead,
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
                                            notif.title,
                                            style: AppTextStyles.titleSmall.copyWith(
                                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (!notif.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryBright,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.message,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notif.timeAgo,
                                      style: AppTextStyles.caption.copyWith(
                                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                                        fontSize: 11,
                                      ),
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
              },
            ),
          ),
        ),
      ),
    );
  }
}
