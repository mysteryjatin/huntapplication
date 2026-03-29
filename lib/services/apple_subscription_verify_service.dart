import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/utils/api_urls.dart';

/// Sends the iOS receipt to your backend for Apple verification and plan unlock.
class AppleSubscriptionVerifyService {
  Future<({bool success, String? message})> verifyPurchase({
    required String receiptData,
  }) async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      return (success: false, message: 'Please sign in to complete your purchase.');
    }

    final uri = ApiUrls.appleVerifyReceipt();
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'receipt_data': receiptData,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final ok = decoded['success'] == true;
          final msg = decoded['data'] is Map
              ? (decoded['data'] as Map)['message']?.toString()
              : null;
          return (success: ok, message: msg ?? 'Subscription updated.');
        }
      } catch (_) {}
      return (success: true, message: 'Subscription updated.');
    }

    String message = 'Could not verify purchase with server';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {}

    return (success: false, message: message);
  }
}
