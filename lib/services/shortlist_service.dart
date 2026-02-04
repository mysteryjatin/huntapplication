import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/shortlist_models.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/utils/api_urls.dart';

class ShortlistService {
  /// transactionType: "rent" | "sale" | null (for all)
  /// page: 1-based page index
  /// limit: items per page
  Future<ShortlistResponse> getShortlist({
    String? transactionType,
    int page = 1,
    int limit = 12,
  }) async {
    final userId = await StorageService.getUserId();

    if (userId == null || userId.isEmpty) {
      throw Exception('User not logged in. Cannot load shortlist.');
    }

    final uri = ApiUrls.shortlist(
      userId: userId,
      transactionType: transactionType,
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
        '📥 SHORTLIST RESPONSE [${response.statusCode}] page=$page type=$transactionType -> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return ShortlistResponse.fromJson(decoded);
      }
    }

    String message = 'Failed to load shortlist';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}

