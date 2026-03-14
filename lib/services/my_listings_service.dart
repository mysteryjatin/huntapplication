import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/my_listings_models.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/utils/api_urls.dart';

class MyListingsService {
  /// status: "all" | "active" | "pending" | "rejected"
  Future<MyListingsResponse> getMyListings({
    String status = 'all',
    int page = 1,
    int limit = 12,
  }) async {
    final ownerId = await StorageService.getUserId();

    if (ownerId == null || ownerId.isEmpty) {
      throw Exception('User not logged in. Cannot load listings.');
    }

    final uri = ApiUrls.myListings(
      ownerId: ownerId,
      status: status,
      page: page,
      limit: limit,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // ignore: avoid_print
    print(
        '📥 MY LISTINGS RESPONSE [${response.statusCode}] status=$status page=$page -> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return MyListingsResponse.fromJson(decoded);
      }
    }

    String message = 'Failed to load my listings';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}

