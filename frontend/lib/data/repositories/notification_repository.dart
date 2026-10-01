import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../models/notification_item.dart';

/// Repository managing user notifications and read/unread state backed by FastAPI / PostgreSQL.
class NotificationRepository {
  static const List<NotificationItem> _initialNotifications = [
    NotificationItem(
      id: 'notif_1',
      title: 'New Connection Request',
      message: 'Sneha Patel (Year 3 · IT) sent you a connection request.',
      type: NotificationType.connection,
      timeAgo: '15m ago',
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_2',
      title: 'Closing Soon: CrowdStrike Internship',
      message: 'The Cybersecurity Analyst Internship deadline is in 4 days. Submit your application!',
      type: NotificationType.opportunity,
      timeAgo: '1h ago',
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_3',
      title: 'New Upvotes on Your Post',
      message: 'Ananya Sharma and 3 others upvoted your comment in the Community discussion.',
      type: NotificationType.like,
      timeAgo: '3h ago',
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_4',
      title: 'New Group Discussion',
      message: 'Cybersecurity & CTF Builders: New writeup posted for "Wireshark PCAP Analysis Challenge".',
      type: NotificationType.group,
      timeAgo: '5h ago',
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_5',
      title: 'Mentorship Update',
      message: 'Rahul Sharma accepted your request for "Practical Packet Analysis Session 1".',
      type: NotificationType.mentor,
      timeAgo: '1d ago',
      isRead: true,
    ),
    NotificationItem(
      id: 'notif_6',
      title: 'New Answer to Your Question',
      message: 'Karthik Raja replied to your discussion on C++ vs Rust for competitive programming.',
      type: NotificationType.comment,
      timeAgo: '2d ago',
      isRead: true,
    ),
    NotificationItem(
      id: 'notif_7',
      title: 'Featured Hackathon Announced',
      message: 'Global AI Innovation Sprint 2026 by Google Cloud is now open for student team registrations.',
      type: NotificationType.opportunity,
      timeAgo: '3d ago',
      isRead: true,
    ),
    NotificationItem(
      id: 'notif_8',
      title: 'Welcome to LinkUp! 🎉',
      message: 'Your student profile is ready. Start by exploring opportunities and joining your college tech groups.',
      type: NotificationType.group,
      timeAgo: '4d ago',
      isRead: true,
    ),
  ];

  final ValueNotifier<List<NotificationItem>> _notificationsNotifier =
      ValueNotifier<List<NotificationItem>>(_initialNotifications);
  bool _isLoading = false;

  ValueListenable<List<NotificationItem>> get notificationsNotifier => _notificationsNotifier;
  List<NotificationItem> get allNotifications => _notificationsNotifier.value;
  bool get isLoading => _isLoading;

  int get unreadCount => _notificationsNotifier.value.where((n) => !n.isRead).length;

  NotificationRepository() {
    fetchNotifications();
  }

  /// Fetches real notifications from GET /api/v1/notifications.
  Future<void> fetchNotifications({int page = 1, int limit = 30}) async {
    _isLoading = true;
    try {
      final response = await ApiClient.instance.get('notifications', queryParams: {
        'page': page,
        'limit': limit,
      });

      if (response is Map && response['items'] is List) {
        final items = (response['items'] as List)
            .map((json) => NotificationItem.fromJson(json as Map<String, dynamic>))
            .toList();
        if (items.isNotEmpty) {
          _notificationsNotifier.value = items;
        }
      }
    } catch (e) {
      debugPrint('[NotificationRepository] Backend notifications sync notice: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Refreshes notifications from backend.
  Future<void> refresh() => fetchNotifications();

  /// Marks a notification as read locally and syncs to PATCH /api/v1/notifications/{id}/read.
  Future<void> markAsRead(String id) async {
    final current = List<NotificationItem>.from(_notificationsNotifier.value);
    final index = current.indexWhere((n) => n.id == id);
    if (index != -1 && !current[index].isRead) {
      current[index] = current[index].copyWith(isRead: true);
      _notificationsNotifier.value = current;

      try {
        await ApiClient.instance.patch('notifications/$id/read');
      } catch (e) {
        debugPrint('[NotificationRepository] Mark read error: $e');
      }
    }
  }

  /// Marks all notifications as read locally and syncs to POST /api/v1/notifications/read-all.
  Future<void> markAllAsRead() async {
    final current = _notificationsNotifier.value.map((n) => n.copyWith(isRead: true)).toList();
    _notificationsNotifier.value = current;

    try {
      await ApiClient.instance.post('notifications/read-all');
    } catch (e) {
      debugPrint('[NotificationRepository] Mark all read error: $e');
    }
  }
}
