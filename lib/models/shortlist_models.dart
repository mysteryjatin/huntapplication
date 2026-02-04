import 'package:hunt_property/models/property_models.dart';

/// Paginated shortlist response from
/// GET /api/favorites/user/{user_id}/shortlist
class ShortlistResponse {
  final List<Property> properties;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const ShortlistResponse({
    required this.properties,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ShortlistResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['properties'] as List<dynamic>? ?? const [];
    final props = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => Property.fromJson(e))
        .toList();

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool _toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final lower = v.toLowerCase();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
      }
      return false;
    }

    return ShortlistResponse(
      properties: props,
      total: _toInt(json['total']),
      page: _toInt(json['page']),
      limit: _toInt(json['limit']),
      totalPages: _toInt(json['total_pages']),
      hasNext: _toBool(json['has_next']),
      hasPrev: _toBool(json['has_prev']),
    );
  }
}

