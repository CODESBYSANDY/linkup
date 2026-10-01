import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/notification_item.dart';

/// Screen displaying student activity notifications and read state management.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.connection:
        return Icons.person_add_rounded;
      case NotificationType.like:
        return Icons.arrow_upward_rounded;
      case NotificationType.comment:
        return Icons.chat_bubble_rounded;
      case NotificationType.opportunity:
        return Icons.lightbulb_rounded;
      case NotificationType.group:
        return Icons.groups_rounded;
      case NotificationType.mentor:
        return Icons.school_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.connection:
        return AppColors.secondary;
      case NotificationType.like:
        return AppColors.primary;
      case NotificationType.comment:
        return const Color(0xFF7C3AED);
      case NotificationType.opportunity:
        return AppColors.warning;
      case NotificationType.group:
        return AppColors.primaryDark;
      case NotificationType.mentor:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              AppServices.notifications.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Mark all as read', style: AppTextStyles.labelMedium),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: AppServices.notifications.notificationsNotifier,
          builder: (context, notifs, _) {
            if (notifs.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                description: 'You are all caught up! Updates regarding opportunities, upvotes, and groups will appear here.',
              );
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: notifs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = notifs[index];
                return InkWell(
                  onTap: () {
                    AppServices.notifications.markAsRead(notif.id);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: notif.isRead ? AppColors.surface : AppColors.softTeal.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: notif.isRead ? AppColors.surfaceSubtle : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getTypeIcon(notif.type),
                            color: _getTypeColor(notif.type),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (!notif.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(notif.message, style: AppTextStyles.bodySmall),
                              const SizedBox(height: 6),
                              Text(notif.timeAgo, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
