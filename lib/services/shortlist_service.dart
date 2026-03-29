import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/shortlist_models.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/utils/api_urls.dart';

class ShortlistService {
  /// API validates `limit` ≤ 100 (Pydantic). Do not exceed this on any request.
  static const int maxPageSize = 100;

  /// Same headers as other authenticated APIs (ProfileService) so favorites persist in DB.
  Future<Map<String, String>> _jsonHeaders() async {
    final h = <String, String>{'Content-Type': 'application/json'};
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

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
      headers: await _jsonHeaders(),
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

  /// All favorited property IDs (paginates with [maxPageSize] until no next page).
  Future<Set<String>> getAllShortlistedPropertyIds({String? transactionType}) async {
    final ids = <String>{};
    var page = 1;
    const maxPages = 50;
    while (page <= maxPages) {
      final res = await getShortlist(
        transactionType: transactionType,
        page: page,
        limit: maxPageSize,
      );
      ids.addAll(res.properties.map((p) => p.id));
      if (!res.hasNext || res.properties.isEmpty) break;
      page++;
    }
    return ids;
  }

  /// Whether [propertyId] appears in the user's shortlist (stops at first matching page).
  Future<bool> isPropertyShortlisted(String propertyId) async {
    final id = propertyId.trim();
    if (id.isEmpty) return false;
    var page = 1;
    const maxPages = 50;
    while (page <= maxPages) {
      final res = await getShortlist(
        page: page,
        limit: maxPageSize,
      );
      for (final p in res.properties) {
        if (p.id == id) return true;
      }
      if (!res.hasNext || res.properties.isEmpty) break;
      page++;
    }
    return false;
  }

  /// Looks up the **favorite document id** (not property id) from shortlist JSON.
  /// Many backends expect `DELETE /api/favorites/{favoriteRecordId}/` while GET embeds property `_id`.
  Future<String?> resolveFavoriteRecordId(String propertyId) async {
    final pid = propertyId.trim();
    if (pid.isEmpty) return null;
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) return null;

    String? favFromItem(Map<String, dynamic> m) {
      for (final key in [
        'favorite_id',
        'favoriteId',
        'favourite_id',
        'favorite_record_id',
      ]) {
        final v = m[key];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      final fav = m['favorite'];
      if (fav is Map && fav['_id'] != null) return fav['_id'].toString();
      // Document shape: { "_id": "<favoriteRowId>", "property_id": "<propertyId>", ... }
      if (m['property_id'] != null &&
          m['_id'] != null &&
          m['property_id'].toString().trim().isNotEmpty) {
        return m['_id'].toString();
      }
      return null;
    }

    String? propIdFromItem(Map<String, dynamic> m) {
      if (m['property_id'] != null) return m['property_id'].toString();
      if (m['propertyId'] != null) return m['propertyId'].toString();
      final prop = m['property'];
      if (prop is Map && prop['_id'] != null) return prop['_id'].toString();
      return m['_id']?.toString();
    }

    var page = 1;
    const maxPages = 50;
    while (page <= maxPages) {
      final uri = ApiUrls.shortlist(
        userId: userId,
        page: page,
        limit: maxPageSize,
      );
      final response = await http.get(uri, headers: await _jsonHeaders());
      if (response.statusCode != 200 && response.statusCode != 201) break;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) break;
      final rawList = decoded['properties'] as List? ?? [];
      for (final raw in rawList) {
        if (raw is! Map) continue;
        final m = Map<String, dynamic>.from(raw as Map);
        if (propIdFromItem(m) == pid) {
          final fid = favFromItem(m);
          if (fid != null && fid.isNotEmpty) return fid;
        }
      }
      final hasNext = decoded['has_next'] == true;
      if (!hasNext) break;
      page++;
    }
    return null;
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
      final resp = await http.post(uri, headers: await _jsonHeaders(), body: body);
      // ignore: avoid_print
      print('📤 ADD TO SHORTLIST [${resp.statusCode}] -> ${resp.body}');
      if (resp.statusCode == 200 ||
          resp.statusCode == 201 ||
          resp.statusCode == 204) {
        return true;
      }
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
  ///
  /// [favoriteRecordId] is the **favorite row id** (from POST add or shortlist JSON), not
  /// the property id. Many backends use `DELETE /api/favorites/{favoriteRecordId}/`.
  /// If omitted, we try [resolveFavoriteRecordId] from GET shortlist.
  Future<bool> removeFromShortlist(
    String propertyId, {
    String? favoriteRecordId,
  }) async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      // ignore: avoid_print
      print('❌ removeFromShortlist: no user id');
      return false;
    }

    final base = ApiUrls.baseUrl;
    final headers = await _jsonHeaders();
    final favId = (favoriteRecordId != null && favoriteRecordId.trim().isNotEmpty)
        ? favoriteRecordId.trim()
        : await resolveFavoriteRecordId(propertyId);

    Future<http.Response> _deleteNoAutoFollow(Uri uri) async {
      final client = http.Client();
      try {
        final req = http.Request('DELETE', uri);
        req.followRedirects = false;
        headers.forEach((k, v) => req.headers[k] = v);
        final streamed = await client.send(req);
        return await http.Response.fromStream(streamed);
      } finally {
        client.close();
      }
    }

    bool _deleteSucceeded(http.Response resp) {
      final code = resp.statusCode;
      if (code == 200 || code == 204) {
        // ignore: avoid_print
        print('✅ REMOVE SHORTLIST: OK ($code)');
        return true;
      }
      // Idempotent: backend returns 404 if row already gone (huntbackend favorites.py)
      if (code == 404) {
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map<String, dynamic>) {
            final detail = decoded['detail']?.toString().toLowerCase() ?? '';
            if (detail.contains('favorite') && detail.contains('not found')) {
              // ignore: avoid_print
              print('✅ REMOVE SHORTLIST: OK (404 already removed)');
              return true;
            }
          }
        } catch (_) {}
      }
      return false;
    }

    Future<bool> _deleteWithRedirects(Uri startUri) async {
      try {
        var uri = startUri;
        for (var hop = 0; hop < 5; hop++) {
          final resp = await _deleteNoAutoFollow(uri);
          // ignore: avoid_print
          print(
              '📤 REMOVE SHORTLIST DELETE [${resp.statusCode}] $uri -> ${resp.body}');

          if (_deleteSucceeded(resp)) return true;

          if (resp.statusCode >= 301 && resp.statusCode <= 308) {
            final location = resp.headers['location'];
            if (location == null || location.isEmpty) return false;
            final next = Uri.tryParse(location);
            if (next == null) return false;
            uri = next.hasScheme ? next : uri.resolve(location);
            // ignore: avoid_print
            print('📤 REMOVE SHORTLIST: follow redirect -> $uri');
            continue;
          }
          return false;
        }
      } catch (e) {
        // ignore: avoid_print
        print('❌ removeFromShortlist DELETE error: $e');
      }
      return false;
    }

    Future<bool> _deleteWithBodyRedirects(Uri startUri, String bodyJson) async {
      try {
        var uri = startUri;
        for (var hop = 0; hop < 5; hop++) {
          final client = http.Client();
          late http.Response resp;
          try {
            final req = http.Request('DELETE', uri);
            req.followRedirects = false;
            headers.forEach((k, v) => req.headers[k] = v);
            req.headers['Content-Type'] = 'application/json';
            req.body = bodyJson;
            final streamed = await client.send(req);
            resp = await http.Response.fromStream(streamed);
          } finally {
            client.close();
          }
          // ignore: avoid_print
          print(
              '📤 REMOVE SHORTLIST DELETE body [${resp.statusCode}] $uri -> ${resp.body}');
          if (_deleteSucceeded(resp)) return true;
          if (resp.statusCode >= 301 && resp.statusCode <= 308) {
            final location = resp.headers['location'];
            if (location == null || location.isEmpty) return false;
            final next = Uri.tryParse(location);
            if (next == null) return false;
            uri = next.hasScheme ? next : uri.resolve(location);
            continue;
          }
          return false;
        }
      } catch (e) {
        // ignore: avoid_print
        print('❌ removeFromShortlist DELETE body error: $e');
      }
      return false;
    }

    // Primary: huntbackend — DELETE /api/favorites/user/{user_id}/property/{property_id}
    // (Do not use /shortlist/... for DELETE; that route does not exist. Do not use
    // DELETE /api/favorites/{id} with property id — that path expects favorite _id.)
    final byUserAndProperty = [
      Uri.parse('$base/api/favorites/user/$userId/property/$propertyId/'),
      Uri.parse('$base/api/favorites/user/$userId/property/$propertyId'),
    ];
    for (final uri in byUserAndProperty) {
      if (await _deleteWithRedirects(uri)) return true;
    }

    // 0) By favorite document id (correct for many FastAPI/Mongo backends)
    if (favId != null && favId.isNotEmpty) {
      final byFav = [
        Uri.parse('$base/api/favorites/$favId/'),
        Uri.parse('$base/api/favorites/$favId'),
        Uri.parse('$base/api/favorites/user/$userId/shortlist/$favId/'),
        Uri.parse('$base/api/favorites/user/$userId/shortlist/$favId'),
      ];
      for (final uri in byFav) {
        if (await _deleteWithRedirects(uri)) return true;
      }
    }

    // 1) User-scoped by property id
    final userScoped = [
      Uri.parse('$base/api/favorites/user/$userId/shortlist/$propertyId/'),
      Uri.parse('$base/api/favorites/user/$userId/shortlist/$propertyId'),
    ];
    for (final uri in userScoped) {
      if (await _deleteWithRedirects(uri)) return true;
    }

    // 2) DELETE collection + body
    try {
      final uri = Uri.parse('$base/api/favorites/user/$userId/shortlist/');
      final bodyJson = jsonEncode({'property_id': propertyId});
      if (await _deleteWithBodyRedirects(uri, bodyJson)) return true;
    } catch (e) {
      // ignore: avoid_print
      print('❌ removeFromShortlist DELETE body outer error: $e');
    }

    // 3) Flat by property id (often wrong if API expects favorite id — still try)
    final flat = [
      Uri.parse('$base/api/favorites/$propertyId/'),
      Uri.parse('$base/api/favorites/$propertyId'),
    ];
    for (final uri in flat) {
      if (await _deleteWithRedirects(uri)) return true;
    }

    // 4) POST fallbacks
    final fallbacks = [
      Uri.parse('$base/api/favorites/remove'),
      Uri.parse('$base/api/favorites/remove/'),
    ];
    final postBodies = <Map<String, dynamic>>[
      {'property_id': propertyId, 'user_id': userId},
      if (favId != null && favId.isNotEmpty)
        {'favorite_id': favId, 'user_id': userId},
    ];
    for (final fallback in fallbacks) {
      for (final payload in postBodies) {
        try {
          final body = jsonEncode(payload);
          final resp = await http.post(
            fallback,
            headers: await _jsonHeaders(),
            body: body,
          );
          // ignore: avoid_print
          print(
              '📤 REMOVE SHORTLIST POST [${resp.statusCode}] $fallback $payload -> ${resp.body}');
          if (resp.statusCode == 200 ||
              resp.statusCode == 201 ||
              resp.statusCode == 204) {
            // ignore: avoid_print
            print('✅ REMOVE SHORTLIST: OK (POST ${resp.statusCode})');
            return true;
          }
        } catch (e) {
          // ignore: avoid_print
          print('❌ removeFromShortlist POST fallback error: $e');
        }
      }
    }

    try {
      final ids = await getAllShortlistedPropertyIds();
      if (!ids.contains(propertyId)) {
        // ignore: avoid_print
        print('✅ REMOVE SHORTLIST: OK (verified absent after attempts)');
        return true;
      }
    } catch (_) {}

    // ignore: avoid_print
    print('❌ REMOVE SHORTLIST: failed — property still in shortlist or unreachable');
    return false;
  }
}

