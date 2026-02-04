import 'package:hunt_property/services/auth_service.dart';

class ApiUrls {
  static const String baseUrl = AuthService.baseUrl;

  static Uri filterScreen({String? transactionType}) {
    // Base endpoint: /api/filter-screen/
    return Uri.parse('$baseUrl/api/filter-screen/').replace(
      queryParameters: (transactionType == null || transactionType.trim().isEmpty)
          ? null
          : {'transaction_type': transactionType.trim()},
    );
  }

  /// Shortlist (favorites) for the current user.
  ///
  /// Base:
  ///   GET /api/favorites/user/{user_id}/shortlist
  ///
  /// With filters:
  ///   ?transaction_type=rent|sale&page=1&limit=12
  static Uri shortlist({
    required String userId,
    String? transactionType,
    int page = 1,
    int limit = 12,
  }) {
    final query = <String, String>{};

    if (transactionType != null && transactionType.trim().isNotEmpty) {
      query['transaction_type'] = transactionType.trim();
    }

    // Pagination
    query['page'] = page.toString();
    query['limit'] = limit.toString();

    final base = '$baseUrl/api/favorites/user/$userId/shortlist';
    return Uri.parse(base).replace(
      queryParameters: query.isEmpty ? null : query,
    );
  }

  /// My listings for a specific owner (current logged-in user).
  ///
  /// Base:
  ///   GET /api/properties/my-listings/{owner_id}
  ///
  /// With filters:
  ///   ?status=all|active|pending|rejected&page=1&limit=12
  static Uri myListings({
    required String ownerId,
    String status = 'all',
    int page = 1,
    int limit = 12,
  }) {
    final query = <String, String>{
      'status': status,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final base = '$baseUrl/api/properties/my-listings/$ownerId';
    return Uri.parse(base).replace(queryParameters: query);
  }

  /// Subscription plans endpoint.
  ///
  /// Base (all plans, no user):
  ///   GET /api/subscription-plans/
  ///
  /// With user (current user's plan):
  ///   GET /api/subscription-plans/?user_id={user_id}
  static Uri subscriptionPlans({String? userId}) {
    final base = '$baseUrl/api/subscription-plans/';
    if (userId != null && userId.isNotEmpty) {
      return Uri.parse(base).replace(
        queryParameters: {'user_id': userId},
      );
    }
    return Uri.parse(base);
  }
}

