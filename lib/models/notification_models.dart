import 'dart:convert';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final bool read;
  final String? actionText;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    required this.read,
    this.actionText,
    this.actionUrl,
    this.data,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsed;
    try {
      final s = json['created_at'] as String?;
      if (s != null && s.isNotEmpty) parsed = DateTime.tryParse(s);
    } catch (_) {}

    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: json['body']?.toString(),
      read: (json['read'] is bool) ? json['read'] as bool : (json['read']?.toString() == 'true'),
      actionText: json['action_text']?.toString(),
      actionUrl: json['action_url']?.toString(),
      data: (json['data'] is Map<String, dynamic>) ? Map<String, dynamic>.from(json['data']) : (json['data'] != null ? jsonDecode(jsonEncode(json['data'])) as Map<String, dynamic> : null),
      createdAt: parsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'read': read,
      'action_text': actionText,
      'action_url': actionUrl,
      'data': data,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

