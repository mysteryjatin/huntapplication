import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hunt_property/services/auth_service.dart';

class NotificationService {
  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> getNotifications(
    String userId, {
    String tab = 'all',
    bool? read,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{
        'tab': tab,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (read != null) params['read'] = read ? 'true' : 'false';
      if (type != null && type.isNotEmpty) params['type'] = type;

      final uri = Uri.parse('$baseUrl/api/notifications/user/$userId').replace(queryParameters: params);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      // ignore: avoid_print
      print('📥 GET NOTIFICATIONS: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'status': response.statusCode, 'body': response.body};
    } catch (e) {
      // ignore: avoid_print
      print('❌ GET NOTIFICATIONS ERROR: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUnreadCount(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifications/user/$userId/unread-count');
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      // ignore: avoid_print
      print('📥 GET UNREAD COUNT: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false};
    } catch (e) {
      // ignore: avoid_print
      print('❌ GET UNREAD COUNT ERROR: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> markRead(String notificationId, {bool read = true}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifications/$notificationId');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'read': read}),
      );
      // ignore: avoid_print
      print('📤 PATCH NOTIFICATION $notificationId -> ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('❌ PATCH NOTIFICATION ERROR: $e');
      return false;
    }
  }

  Future<bool> markAllRead(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifications/user/$userId/mark-all-read');
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'});
      // ignore: avoid_print
      print('📤 MARK ALL READ -> ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('❌ MARK ALL READ ERROR: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifications/$notificationId');
      final response = await http.delete(uri, headers: {'Content-Type': 'application/json'});
      // ignore: avoid_print
      print('📤 DELETE NOTIFICATION $notificationId -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // ignore: avoid_print
      print('❌ DELETE NOTIFICATION ERROR: $e');
      return false;
    }
  }
}

