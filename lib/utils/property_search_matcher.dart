import 'package:hunt_property/models/property_models.dart';

/// Client-side refinement for search: BHK, city/locality/address, title, description, amenities.
/// Use when the API misses amenity/location matches or returns an empty list.
class PropertySearchMatcher {
  PropertySearchMatcher._();

  /// Matches "2bhk", "2 bhk", "3-bhk", etc.
  static int? parseBhk(String qLower) {
    final m = RegExp(r'(\d+)\s*[-]?\s*bhk').firstMatch(qLower);
    if (m == null) return null;
    final n = int.tryParse(m.group(1)!);
    if (n == null || n <= 0) return null;
    return n;
  }

  /// Text left after removing BHK phrases (for gym, city names, etc.).
  static String residualAfterBhk(String qLower) {
    return qLower
        .replaceAll(RegExp(r'\d+\s*[-]?\s*bhk'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _txnMatch(Property p, String uiType) {
    final pt = p.transactionType.toLowerCase();
    final want = uiType.toUpperCase();
    if (want == 'RENT') return pt == 'rent';
    return pt == 'sale' || pt == 'sell';
  }

  static bool _fieldMatches(Property p, String residual) {
    bool has(String? s) =>
        s != null && s.toLowerCase().contains(residual);

    if (has(p.city)) return true;
    if (has(p.locality)) return true;
    if (has(p.address)) return true;
    if (has(p.title)) return true;
    if (has(p.description)) return true;
    for (final a in p.amenities) {
      if (a.toLowerCase().contains(residual)) return true;
    }
    return false;
  }

  /// Filters by BUY/RENT, optional BHK, then residual query across location + amenities + text.
  static List<Property> applyClientFilters(
    List<Property> candidates,
    String query,
    String uiType,
    int? bhk,
  ) {
    final qLower = query.toLowerCase().trim();
    final resolvedBhk = bhk ?? parseBhk(qLower);

    var list = candidates.where((p) => _txnMatch(p, uiType)).toList();

    if (resolvedBhk != null && resolvedBhk > 0) {
      list = list.where((p) => p.bedrooms == resolvedBhk).toList();
    }

    final residual = residualAfterBhk(qLower);
    if (residual.isEmpty) return list;

    return list.where((p) => _fieldMatches(p, residual)).toList();
  }

  /// Applies [applyClientFilters] to API results; if none match, retries on [allProperties].
  static List<Property> withFallback(
    List<Property> apiResults,
    List<Property> allProperties,
    String query,
    String uiType,
    int? bhk,
  ) {
    final first = applyClientFilters(apiResults, query, uiType, bhk);
    if (first.isNotEmpty) return first;

    final trimmed = query.trim();
    if (trimmed.isEmpty || allProperties.isEmpty) return first;

    return applyClientFilters(allProperties, query, uiType, bhk);
  }
}
