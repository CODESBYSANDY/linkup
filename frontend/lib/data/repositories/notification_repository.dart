import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../models/notification_item.dart';

/// Repository managing user notifications and read/unread state backed by FastAPI / PostgreSQL.
class NotificationRepository {
  final ValueNotifier<List<NotificationItem>> _notificationsNotifier =
      ValueNotifier<List<NotificationItem>>([]);
  bool _isLoading = false;

  ValueListenable<List<NotificationItem>> get notificationsNotifier => _notificationsNotifier;
  List<NotificationItem> get allNotifications => _notificationsNotifier.value;
  bool get isLoading => _isLoading;

  int get unreadCount => _notificationsNotifier.value.where((n) => !n.isRead).length;

  NotificationRepository() {
    if (ApiClient.instance.isAuthenticated) {
      fetchNotifications();
    }
  }

  /// Resets notifications state on user logout to prevent cross-session leakage.
  void reset() {
    _notificationsNotifier.value = [];
    _isLoading = false;
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
        _notificationsNotifier.value = items;
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
