/// Notification type matching backend NotificationType enum.
enum NotificationType {
  connection,
  like,
  comment,
  opportunity,
  group,
  mentor,
  system,
}

extension NotificationTypeExtension on NotificationType {
  static NotificationType fromString(String? val) {
    if (val == null) return NotificationType.system;
    switch (val.toLowerCase()) {
      case 'connection':
      case 'connection_request':
      case 'connection_accepted':
        return NotificationType.connection;
      case 'like':
      case 'post_like':
        return NotificationType.like;
      case 'comment':
      case 'post_comment':
        return NotificationType.comment;
      case 'opportunity':
      case 'opportunity_deadline':
      case 'opportunity_closing_soon':
        return NotificationType.opportunity;
      case 'group':
      case 'group_activity':
        return NotificationType.group;
      case 'mentor':
      case 'mentorship_accepted':
        return NotificationType.mentor;
      default:
        return NotificationType.system;
    }
  }
}

/// Model representing a student notification, synchronized with FastAPI NotificationResponse.
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String timeAgo;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
    this.data,
    this.createdAt,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? timeAgo,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      type: NotificationTypeExtension.fromString(json['type']?.toString()),
      timeAgo: json['time_ago'] as String? ?? json['timeAgo'] as String? ?? 'recently',
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : null,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'time_ago': timeAgo,
      'is_read': isRead,
      'data': data,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
