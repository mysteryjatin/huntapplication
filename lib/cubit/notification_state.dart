import 'package:hunt_property/models/notification_models.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int page;
  final int limit;
  final int total;
  final bool hasNext;

  NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasNext,
  });
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

