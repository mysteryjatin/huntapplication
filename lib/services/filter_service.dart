import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/filter_models.dart';
import 'package:hunt_property/utils/api_urls.dart';

class FilterService {
  /// transactionType: "sale" | "rent" | null (for all)
  Future<FilterScreenResponse> getFilterScreen({String? transactionType}) async {
    Future<FilterScreenResponse> fetchOnce({String? txn}) async {
      final uri = ApiUrls.filterScreen(transactionType: txn);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      // ignore: avoid_print
      print('📥 FILTER SCREEN RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return FilterScreenResponse.fromJson(decoded);
        }
      }

      String message = 'Failed to load filters';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['detail'] != null) {
          message = body['detail'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    bool looksEmpty(FilterScreenResponse r) {
      return r.transactionTypes.isEmpty &&
          r.propertyCategories.isEmpty &&
          r.propertySubtypes.isEmpty &&
          r.furnishingOptions.isEmpty &&
          r.facingOptions.isEmpty &&
          r.cities.isEmpty &&
          r.localities.isEmpty &&
          r.bedrooms.isEmpty &&
          r.bathrooms.isEmpty;
    }

    final first = await fetchOnce(txn: transactionType);

    // Backend (abhi) sale/rent pe empty data de sakta hai.
    // UX ke liye fallback: all-filters endpoint call kar do.
    if (transactionType != null && transactionType.trim().isNotEmpty && looksEmpty(first)) {
      return await fetchOnce(txn: null);
    }

    return first;
  }
}

