import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/subscription_plans_models.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/utils/api_urls.dart';

class SubscriptionPlansService {
  /// Fetches subscription plans.
  /// If userId is provided, includes current user's plan info.
  /// If userId is null, fetches all plans without user context.
  Future<SubscriptionPlansResponse> getSubscriptionPlans({String? userId}) async {
    // If userId not provided, try to get from storage
    final effectiveUserId = userId ?? await StorageService.getUserId();

    final uri = ApiUrls.subscriptionPlans(userId: effectiveUserId);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // ignore: avoid_print
    print(
        '📥 SUBSCRIPTION PLANS RESPONSE [${response.statusCode}] userId=$effectiveUserId -> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return SubscriptionPlansResponse.fromJson(decoded);
      }
    }

    String message = 'Failed to load subscription plans';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}
