import 'package:bloc/bloc.dart';
import 'package:hunt_property/cubit/notification_state.dart';
import 'package:hunt_property/repositories/notification_repository.dart';
import 'package:hunt_property/models/notification_models.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repo;
  String? _lastUserId;
  String _lastTab = 'all';
  int _lastPage = 1;
  int _lastLimit = 20;

  NotificationCubit(this.repo) : super(NotificationInitial());

  Future<void> fetchNotifications({
    required String userId,
    String tab = 'all',
    bool? read,
    String? type,
    int page = 1,
    int limit = 20,
    bool append = false,
  }) async {
    _lastUserId = userId;
    _lastTab = tab;
    _lastPage = page;
    _lastLimit = limit;

    // If not appending, show loading indicator
    if (!append) emit(NotificationLoading());

    try {
      final resp = await repo.fetchNotifications(userId: userId, tab: tab, read: read, type: type, page: page, limit: limit);
      if (resp['success'] == true) {
        final newList = (resp['notifications'] as List<NotificationModel>);

        if (append && state is NotificationLoaded) {
          final prev = state as NotificationLoaded;
          final combined = <NotificationModel>[];
          combined.addAll(prev.notifications);
          combined.addAll(newList);
          emit(NotificationLoaded(
            notifications: combined,
            unreadCount: (resp['unread_count'] ?? prev.unreadCount) as int,
            page: (resp['page'] ?? page) as int,
            limit: (resp['limit'] ?? limit) as int,
            total: (resp['total'] ?? combined.length) as int,
            hasNext: resp['has_next'] ?? false,
          ));
        } else {
          emit(NotificationLoaded(
            notifications: newList,
            unreadCount: (resp['unread_count'] ?? 0) as int,
            page: (resp['page'] ?? page) as int,
            limit: (resp['limit'] ?? limit) as int,
            total: (resp['total'] ?? newList.length) as int,
            hasNext: resp['has_next'] ?? false,
          ));
        }
        return;
      }

      emit(NotificationError('Failed to load notifications'));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> refresh() async {
    if (_lastUserId == null) return;
    await fetchNotifications(userId: _lastUserId!, tab: _lastTab, page: _lastPage, limit: _lastLimit);
  }

  Future<void> markRead(String notificationId) async {
    if (notificationId.isEmpty) return;
    try {
      await repo.markRead(notificationId, read: true);
      await refresh();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    if (_lastUserId == null) return;
    try {
      await repo.markAllRead(_lastUserId!);
      await refresh();
    } catch (_) {}
  }

  Future<void> deleteNotification(String notificationId) async {
    if (notificationId.isEmpty) return;
    try {
      final ok = await repo.deleteNotification(notificationId);
      if (ok) await refresh();
    } catch (_) {}
  }
}

