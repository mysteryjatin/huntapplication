import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/order_history_models.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/utils/api_urls.dart';

class OrderHistoryService {
  /// status: "all" | "pending" | "success" | "invalid"
  Future<OrderHistoryResponse> getOrderHistory({
    String status = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    final userId = await StorageService.getUserId();

    if (userId == null || userId.isEmpty) {
      throw Exception('User not logged in. Cannot load order history.');
    }

    final uri = ApiUrls.orderHistory(
      userId: userId,
      status: status == 'all' ? null : status,
      page: page,
      limit: limit,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return OrderHistoryResponse.fromJson(decoded);
      }
    }

    String message = 'Failed to load order history';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }

  Future<OrderItem?> getOrderById(String orderId) async {
    final uri = ApiUrls.orderById(orderId);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return OrderItem.fromJson(decoded);
      }
    }
    return null;
  }
}
