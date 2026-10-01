/// Notification type
enum NotificationType {
  connection,
  like,
  comment,
  opportunity,
  group,
  mentor,
}

/// Model representing a student notification.
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String timeAgo;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? timeAgo,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
    );
  }
}
