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
 
  /// Add property to user's shortlist (favorites).
  /// Returns true on success.
  Future<bool> addToShortlist(String propertyId) async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      // ignore: avoid_print
      print('❌ addToShortlist: no user id');
      return false;
    }

    final uri = Uri.parse('${ApiUrls.baseUrl}/api/favorites/');
    try {
      final body = jsonEncode({'property_id': propertyId, 'user_id': userId});
      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
      // ignore: avoid_print
      print('📤 ADD TO SHORTLIST [${resp.statusCode}] -> ${resp.body}');
      if (resp.statusCode == 200 || resp.statusCode == 201) return true;
      // Treat common 'already in favorites' response as success
      if (resp.statusCode == 400) {
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map<String, dynamic> && decoded['detail']?.toString().toLowerCase().contains('already') == true) {
            return true;
          }
        } catch (_) {}
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('❌ addToShortlist error: $e');
      return false;
    }
  }

  /// Remove property from user's shortlist.
  /// Returns true on success.
  Future<bool> removeFromShortlist(String propertyId) async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      // ignore: avoid_print
      print('❌ removeFromShortlist: no user id');
      return false;
    }

    // huntbackend: DELETE /api/favorites/user/{user_id}/property/{property_id}
    // (DELETE /api/favorites/{id} expects favorite document _id, not property id.)
    final base = ApiUrls.baseUrl;
    final tryDeletes = [
      Uri.parse('$base/api/favorites/user/$userId/property/$propertyId/'),
      Uri.parse('$base/api/favorites/user/$userId/property/$propertyId'),
    ];
    for (final tryDelete in tryDeletes) {
      try {
        var resp = await http.delete(
          tryDelete,
          headers: {
            'Content-Type': 'application/json',
          },
        );

        // ignore: avoid_print
        print(
            '📤 REMOVE FROM SHORTLIST DELETE [${resp.statusCode}] $tryDelete -> ${resp.body}');

        if (resp.statusCode == 200 || resp.statusCode == 204) return true;
        if (resp.statusCode == 404) {
          try {
            final decoded = jsonDecode(resp.body);
            if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
              return true;
            }
          } catch (_) {}
        }

        if (resp.statusCode == 301 ||
            resp.statusCode == 302 ||
            resp.statusCode == 307 ||
            resp.statusCode == 308) {
          final location = resp.headers['location'];
          if (location != null && location.isNotEmpty) {
            try {
              final redirectUri = Uri.parse(location);
              resp = await http.delete(
                redirectUri,
                headers: {
                  'Content-Type': 'application/json',
                },
              );
              // ignore: avoid_print
              print(
                  '📤 REMOVE FROM SHORTLIST DELETE (redirect) [${resp.statusCode}] -> ${resp.body}');
              if (resp.statusCode == 200 || resp.statusCode == 204) return true;
              if (resp.statusCode == 404) {
                try {
                  final decoded = jsonDecode(resp.body);
                  if (decoded is Map<String, dynamic> &&
                      decoded['detail'] != null) {
                    return true;
                  }
                } catch (_) {}
              }
            } catch (e) {
              // ignore: avoid_print
              print('❌ REMOVE FROM SHORTLIST REDIRECT ERROR: $e');
            }
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('❌ removeFromShortlist DELETE error: $e');
      }
    }

    // Fallback: POST to /api/favorites/remove with body (if backend supports it).
    final fallback = Uri.parse('${ApiUrls.baseUrl}/api/favorites/remove');
    try {
      final body = jsonEncode({'property_id': propertyId, 'user_id': userId});
      final resp = await http.post(
        fallback,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      // ignore: avoid_print
      print('📤 REMOVE FROM SHORTLIST FALLBACK POST [${resp.statusCode}] -> ${resp.body}');
      if (resp.statusCode == 200 || resp.statusCode == 201) return true;
    } catch (e) {
      // ignore: avoid_print
      print('❌ removeFromShortlist fallback error: $e');
    }

    return false;
  }
}

