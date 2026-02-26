import 'package:hunt_property/models/notification_models.dart';
import 'package:hunt_property/services/notification_service.dart';

class NotificationRepository {
  final NotificationService service;
  NotificationRepository({NotificationService? service}) : service = service ?? NotificationService();

  /// Fetch notifications and convert to NotificationModel list with paging/meta
  Future<Map<String, dynamic>> fetchNotifications({
    required String userId,
    String tab = 'all',
    bool? read,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await service.getNotifications(userId, tab: tab, read: read, type: type, page: page, limit: limit);
    if (resp is Map<String, dynamic> && resp['notifications'] is List) {
      final list = (resp['notifications'] as List).whereType<Map<String, dynamic>>().map((e) => NotificationModel.fromJson(e)).toList();
      return {
        'success': true,
        'notifications': list,
        'total': resp['total'] ?? list.length,
        'page': resp['page'] ?? page,
        'limit': resp['limit'] ?? limit,
        'total_pages': resp['total_pages'] ?? 1,
        'has_next': resp['has_next'] ?? false,
        'has_prev': resp['has_prev'] ?? false,
        'unread_count': resp['unread_count'] ?? 0,
      };
    }
    return {'success': false};
  }

  Future<int> getUnreadCount(String userId) async {
    final resp = await service.getUnreadCount(userId);
    if (resp['success'] == true && resp['data'] is Map && resp['data']['unread_count'] != null) {
      return (resp['data']['unread_count'] as num).toInt();
    }
    return 0;
  }

  Future<bool> markRead(String notificationId, {bool read = true}) async {
    return await service.markRead(notificationId, read: read);
  }

  Future<bool> markAllRead(String userId) async {
    return await service.markAllRead(userId);
  }

  Future<bool> deleteNotification(String notificationId) async {
    return await service.deleteNotification(notificationId);
  }
}

