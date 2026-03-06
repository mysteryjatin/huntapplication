import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:hunt_property/models/filter_models.dart';

/// Converts month name (e.g. "April") or "1"-"12" to backend integer 1-12.
/// Also understands relative labels from the filter UI like:
/// "Any Time", "Immediately", "Within 1 Month", "After 1 Month",
/// "Within 3 Month", "After 3 Month".
/// Returns null if it cannot determine a value (meaning: don't filter).
int? _monthNameToInt(String name) {
  final s = name.trim();
  if (s.isEmpty) return null;

  // Direct numeric "1".."12"
  final parsed = int.tryParse(s);
  if (parsed != null && parsed >= 1 && parsed <= 12) return parsed;

  final lower = s.toLowerCase();

  // Relative availability labels used in filter sheet
  if (lower.contains('any time')) {
    // Any time = no filter
    return null;
  }
  if (lower.contains('immediately')) {
    return 1;
  }
  if (lower.contains('within') && lower.contains('1') && lower.contains('month')) {
    return 1;
  }
  if (lower.contains('after') && lower.contains('1') && lower.contains('month')) {
    return 2;
  }
  if (lower.contains('within') && lower.contains('3') && lower.contains('month')) {
    return 3;
  }
  if (lower.contains('after') && lower.contains('3') && lower.contains('month')) {
    return 4;
  }
  if (lower.contains('after') && lower.contains('7') && lower.contains('month')) {
    return 7;
  }
  if (lower.contains('after') && lower.contains('9') && lower.contains('month')) {
    return 9;
  }

  // Calendar month names
  const months = [
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
  ];
  final i = months.indexOf(lower);
  return i >= 0 ? i + 1 : null;
}

String _possessionStatusToLabel(String s) {
  final raw = s.trim();
  final lower = raw.toLowerCase();

  // If already label-like, return a consistent label
  if (lower.contains('under') && lower.contains('construction')) {
    return 'Under Construction';
  }
  if (lower.contains('ready') && lower.contains('move')) {
    return 'Ready to move';
  }

  // Handle backend "value" form too
  if (lower == 'under_construction') return 'Under Construction';
  if (lower == 'ready_to_move') return 'Ready to move';

  return raw;
}

String _possessionStatusToValue(String s) {
  final raw = s.trim();
  final lower = raw.toLowerCase();
  if (lower.contains('under') && lower.contains('construction')) {
    return 'under_construction';
  }
  if (lower.contains('ready') && lower.contains('move')) {
    return 'ready_to_move';
  }
  if (lower == 'under_construction' || lower == 'ready_to_move') return lower;
  return lower.replaceAll(' ', '_');
}

String _ageOfConstructionToLabel(String s) {
  final raw = s.trim();
  final lower = raw.toLowerCase();

  switch (lower) {
    case 'new_construction':
      return 'New Construction';
    case 'less_than_5_years':
      return 'Less than 5 Years';
    case '5_to_10_years':
      return '5 to 10 Years';
    case '10_to_15_years':
      return '10 to 15 Years';
    case '15_to_20_years':
      return '15 to 20 Years';
    case '15_to_20_plus_years':
      return '15 to 20+ Years';
  }

  return raw;
}

String _ageOfConstructionToValue(String s) {
  final raw = s.trim();
  final lower = raw.toLowerCase();

  if (lower == 'new construction') return 'new_construction';
  if (lower == 'less than 5 years') return 'less_than_5_years';
  if (lower == '5 to 10 years') return '5_to_10_years';
  if (lower == '10 to 15 years') return '10_to_15_years';
  if (lower == '15 to 20 years') return '15_to_20_years';
  if (lower == '15 to 20+ years') return '15_to_20_plus_years';

  if (lower.contains('new') && lower.contains('construction')) {
    return 'new_construction';
  }

  if (lower.contains('less') && lower.contains('5')) return 'less_than_5_years';
  if (lower.contains('5') && lower.contains('10')) return '5_to_10_years';
  if (lower.contains('10') && lower.contains('15')) return '10_to_15_years';
  if (lower.contains('15') && lower.contains('20') && lower.contains('+')) {
    return '15_to_20_plus_years';
  }
  if (lower.contains('15') && lower.contains('20')) return '15_to_20_years';

  if (lower == 'new_construction' ||
      lower == 'less_than_5_years' ||
      lower == '5_to_10_years' ||
      lower == '10_to_15_years' ||
      lower == '15_to_20_years' ||
      lower == '15_to_20_plus_years') {
    return lower;
  }

  return lower.replaceAll(' ', '_');
}

String _furnishingToKebabLower(String s) {
  return s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
}

class PropertyService {
  // Re‑use the same base URL as auth
  static const String baseUrl = AuthService.baseUrl;
 
  /// Delete a property by id.
  /// Returns true on success, false otherwise.
  Future<bool> deleteProperty(String propertyId) async {
    try {
      if (propertyId.isEmpty) return false;
      final uri = Uri.parse('$baseUrl/api/properties/$propertyId/');

      // Initial DELETE attempt
      var response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // ignore: avoid_print
      print('📤 DELETE PROPERTY [$propertyId] -> ${response.statusCode} ${response.body}');

      // Some servers respond with 301/302/307 redirect for non-GET methods.
      // The http package does not auto-follow redirects for DELETE, so handle common redirect statuses.
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        final location = response.headers['location'];
        if (location != null && location.isNotEmpty) {
          try {
            final redirectUri = Uri.parse(location);
            response = await http.delete(
              redirectUri,
              headers: {
                'Content-Type': 'application/json',
              },
            );
            // ignore: avoid_print
            print('📤 DELETE PROPERTY (redirect) [$propertyId] -> ${response.statusCode} ${response.body}');
          } catch (e) {
            // ignore: avoid_print
            print('❌ DELETE PROPERTY REDIRECT ERROR: $e');
            return false;
          }
        }
      }

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // ignore: avoid_print
      print('❌ DELETE PROPERTY ERROR: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> createProperty(
      Map<String, dynamic> payload) async {
    try {
      // NOTE: FastAPI is configured with a trailing slash for this route:
      // POST /api/properties/
      // Using the exact path avoids a 307 Temporary Redirect.
      final uri = Uri.parse('$baseUrl/api/properties/');

      // Debug: log outgoing payload
      // This will help see exactly what is being sent to the backend
      // in the Flutter debug console.
      // ignore: avoid_print
      print('📤 CREATE PROPERTY PAYLOAD: $payload');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // Debug: log response
      // ignore: avoid_print
      print(
          '📥 CREATE PROPERTY RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        String errorMessage = 'Failed to create property';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['detail'] != null) {
            errorMessage = body['detail'].toString();
          }
        } catch (_) {
          // ignore JSON parse error and use default error message
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ CREATE PROPERTY ERROR: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Upload a single image file to the backend upload endpoint.
  /// Returns the full HTTP URL on success, or null on failure.
  Future<String?> uploadImage(File file) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload/image');

      final request = http.MultipartRequest('POST', uri);
      // Attach file under field name 'file'
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send request
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      // Debug
      // ignore: avoid_print
      print('📤 UPLOAD IMAGE RESPONSE: ${streamed.statusCode} $body');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['url'] != null) {
          final String path = decoded['url'].toString();
          if (path.startsWith('http')) {
            return path;
          } else {
            return '$baseUrl$path';
          }
        }
      }

      return null;
    } catch (e) {
      // ignore: avoid_print
      print('❌ UPLOAD IMAGE ERROR: $e');
      return null;
    }
  }

  Future<List<Property>> getProperties() async {
    // Default to a wider page size so newly created properties appear.
    return getPropertiesPaged(page: 1, limit: 50);
  }

  /// Fetch properties with pagination support.
  /// Defaults to page=1 and limit=50 to ensure newly created properties appear.
  Future<List<Property>> getPropertiesPaged({int page = 1, int limit = 50}) async {
    try {
      // Matching the backend route with trailing slash: GET /api/properties/
      final uri = Uri.parse('$baseUrl/api/properties/?page=$page&limit=$limit');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // ignore: avoid_print
      print(
          '📥 GET PROPERTIES RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        dynamic list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          // Try common envelope keys - backend returns PropertyListResponse with 'properties' field
          if (decoded['properties'] is List) {
            list = decoded['properties'];
          } else if (decoded['items'] is List) {
            list = decoded['items'];
          } else if (decoded['data'] is List) {
            list = decoded['data'];
          } else if (decoded['results'] is List) {
            list = decoded['results'];
          }
        }

        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => Property.fromJson(e))
              .toList();
        }
      }

      return [];
    } catch (e) {
      // ignore: avoid_print
      print('❌ GET PROPERTIES ERROR: $e');
      return [];
    }
  }

  /// Search properties using query text and optional filters.
  /// Builds query parameters and calls the same properties endpoint.
  Future<List<Property>> searchProperties({
    String query = '',
    FilterSelection? filters,
    String type = 'BUY',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      Map<String, String> buildParams({
        required bool useLabelEncoding,
        required bool furnishingKebabLower,
      }) {
        final params = <String, String>{
          'page': page.toString(),
          'limit': limit.toString(),
        };

        if (query.trim().isNotEmpty) params['search'] = query.trim();

        // Map UI type to backend transaction_type.
        final lower = type.toLowerCase();
        final txn = lower == 'rent' ? 'rent' : 'sale';
        params['transaction_type'] = txn;

        if (filters != null) {
          if (filters.city != null && filters.city!.isNotEmpty) {
            params['city'] = filters.city!;
          }
          if (filters.locality != null && filters.locality!.isNotEmpty) {
            params['locality'] = filters.locality!;
          }
          if (filters.propertyCategory != null &&
              filters.propertyCategory!.isNotEmpty) {
            params['property_category'] = filters.propertyCategory!;
          }
          if (filters.propertySubtype != null &&
              filters.propertySubtype!.isNotEmpty) {
            params['property_subtype'] = filters.propertySubtype!;
          }
          if (filters.budgetMin != null) {
            params['min_price'] = filters.budgetMin!.toString();
          }
          if (filters.budgetMax != null) {
            params['max_price'] = filters.budgetMax!.toString();
          }
          if (filters.areaMin != null) {
            params['min_area'] = filters.areaMin!.toString();
          }
          if (filters.areaMax != null) {
            params['max_area'] = filters.areaMax!.toString();
          }

          if (filters.bedrooms != null) {
            params['min_bedrooms'] = filters.bedrooms!.toString();
          } else if (filters.bedroomsList != null &&
              filters.bedroomsList!.isNotEmpty) {
            final minBhk = filters.bedroomsList!
                .where((v) => v > 0)
                .fold<int>(0, (min, v) {
              if (min == 0) return v;
              return v < min ? v : min;
            });
            if (minBhk > 0) {
              params['min_bedrooms'] = minBhk.toString();
            }
          }

          if (filters.bathrooms != null) {
            params['bathrooms'] = filters.bathrooms!.toString();
          }

          if (filters.furnishing != null && filters.furnishing!.isNotEmpty) {
            final raw = filters.furnishing!.trim();
            params['furnishing'] =
                furnishingKebabLower ? _furnishingToKebabLower(raw) : raw;
          }

          if (filters.facing != null && filters.facing!.isNotEmpty) {
            params['facing'] = filters.facing!.trim().toLowerCase();
          }

          if (filters.possessionStatus != null &&
              filters.possessionStatus!.isNotEmpty) {
            final raw = filters.possessionStatus!;
            params['possession_status'] = useLabelEncoding
                ? _possessionStatusToLabel(raw)
                : _possessionStatusToValue(raw);
          }

          if (filters.availabilityMonth != null &&
              filters.availabilityMonth!.isNotEmpty) {
            final monthInt = _monthNameToInt(filters.availabilityMonth!);
            if (monthInt != null) {
              params['availability_month'] = monthInt.toString();
            }
          }
          if (filters.availabilityYear != null &&
              filters.availabilityYear!.isNotEmpty) {
            params['availability_year'] = filters.availabilityYear!;
          }

          if (filters.ageOfConstruction != null &&
              filters.ageOfConstruction!.isNotEmpty) {
            final raw = filters.ageOfConstruction!.first;
            params['age_of_construction'] = useLabelEncoding
                ? _ageOfConstructionToLabel(raw)
                : _ageOfConstructionToValue(raw);
          }

          if (filters.storeRoom != null) {
            params['store_room'] = filters.storeRoom! ? '1' : '0';
          }
          if (filters.servantRoom != null) {
            params['servant_room'] = filters.servantRoom! ? '1' : '0';
          }
        }

        return params;
      }

      Future<List<Property>> fetchOnce(
        Map<String, String> params, {
        String? tag,
      }) async {
        final uri =
            Uri.parse('$baseUrl/api/properties/').replace(queryParameters: params);

        // ignore: avoid_print
        print(tag == null
            ? '🔎 SEARCH PROPERTIES URI: $uri'
            : '🔎 SEARCH PROPERTIES URI [$tag]: $uri');

        final response = await http.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        );

        // ignore: avoid_print
        print('📥 SEARCH PROPERTIES RESPONSE: ${response.statusCode} ${response.body}');

        if (response.statusCode != 200 && response.statusCode != 201) {
          return [];
        }

        final decoded = jsonDecode(response.body);
        dynamic list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          if (decoded['properties'] is List) {
            list = decoded['properties'];
          } else if (decoded['items'] is List) {
            list = decoded['items'];
          } else if (decoded['data'] is List) {
            list = decoded['data'];
          } else if (decoded['results'] is List) {
            list = decoded['results'];
          }
        }

        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => Property.fromJson(e))
              .toList();
        }

        return [];
      }

      final hasSensitiveTextFilters = filters != null &&
          ((filters!.furnishing != null && filters.furnishing!.isNotEmpty) ||
              (filters.possessionStatus != null &&
                  filters.possessionStatus!.isNotEmpty) ||
              (filters.ageOfConstruction != null &&
                  filters.ageOfConstruction!.isNotEmpty));

      // Attempt 1: use "value" encoding (from filter API) + kebab-case furnishing
      final res1 = await fetchOnce(
        buildParams(useLabelEncoding: false, furnishingKebabLower: true),
      );
      if (res1.isNotEmpty || !hasSensitiveTextFilters) return res1;

      // Attempt 2: use "label" encoding + raw furnishing
      final res2 = await fetchOnce(
        buildParams(useLabelEncoding: true, furnishingKebabLower: false),
        tag: 'label',
      );
      if (res2.isNotEmpty) return res2;

      // Attempt 3: label encoding + kebab furnishing (some backends store lowercase)
      final res3 = await fetchOnce(
        buildParams(useLabelEncoding: true, furnishingKebabLower: true),
        tag: 'label+kebab',
      );
      return res3;
    } catch (e) {
      // ignore: avoid_print
      print('❌ SEARCH PROPERTIES ERROR: $e');
      return [];
    }
  }

  // Get properties count for current user
  Future<int> getUserPropertiesCount() async {
    try {
      final userId = await StorageService.getUserId();
      print('🔍 getUserPropertiesCount - User ID: $userId');
      if (userId == null || userId.isEmpty || userId == '000000000000000000000000') {
        print('⚠️ getUserPropertiesCount - No valid user ID, returning 0');
        return 0;
      }

      final allProperties = await getProperties();
      print('📊 getUserPropertiesCount - Total properties fetched: ${allProperties.length}');
      
      // Filter properties by owner_id (case-insensitive string comparison)
      final userProperties = allProperties.where((property) {
        final propertyOwnerId = property.ownerId?.toString().trim() ?? '';
        final currentUserId = userId.toString().trim();
        
        // Compare both as strings, case-insensitive
        final matches = propertyOwnerId.toLowerCase() == currentUserId.toLowerCase();
        
        if (matches) {
          print('✅ Found matching property: ${property.id}, owner_id: $propertyOwnerId, user_id: $currentUserId');
        } else {
          print('   Property ${property.id}: owner_id="$propertyOwnerId" != user_id="$currentUserId"');
        }
        return matches;
      }).toList();
      
      print('🎯 getUserPropertiesCount - User properties count: ${userProperties.length}');
      print('   User ID used for comparison: $userId');
      return userProperties.length;
    } catch (e, stackTrace) {
      print('❌ GET USER PROPERTIES COUNT ERROR: $e');
      print('❌ Stack Trace: $stackTrace');
      return 0;
    }
  }
 
  /// Fetch home screen sections from backend: top_selling_projects,
  /// recommend_your_location, property_for_rent.
  /// Returns a map: { 'success': bool, 'sections': { key: { 'section_title': String, 'properties': List<Property> } } }
  Future<Map<String, dynamic>> getHomeSections({
    String city = 'Chennai',
    String? userId,
    int limit = 10,
    String? transactionType,
    String? propertyCategory,
  }) async {
    try {
      final params = <String, String>{
        'city': city,
        'limit': limit.clamp(1, 20).toString(),
      };
      if (userId != null && userId.isNotEmpty) params['user_id'] = userId;
      if (transactionType != null && transactionType.isNotEmpty) params['transaction_type'] = transactionType;
      if (propertyCategory != null && propertyCategory.isNotEmpty) params['property_category'] = propertyCategory;

      final uri = Uri.parse('$baseUrl/api/home/').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      // ignore: avoid_print
      print('📥 GET HOME SECTIONS RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        // Pretty-print decoded response for debugging
        try {
          final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
          print('📥 GET HOME SECTIONS DECODED:\n$pretty');
        } catch (_) {
          // ignore
        }

        // Handle cases where decoded['data'] might be a JSON-encoded string
        Map<String, dynamic> dataMap = {};
        if (decoded is Map) {
          final dataCandidate = decoded['data'];
          if (dataCandidate is Map<String, dynamic>) {
            dataMap = dataCandidate;
          } else if (dataCandidate is String) {
            try {
              final parsed = jsonDecode(dataCandidate);
              if (parsed is Map<String, dynamic>) dataMap = parsed;
            } catch (_) {
              // leave empty
            }
          }
        }

        if (dataMap.isNotEmpty) {
          final Map<String, dynamic> sections = {};
          for (final key in ['top_selling_projects', 'recommend_your_location', 'property_for_rent']) {
            final sectionCandidate = dataMap[key];
            Map<String, dynamic> section = {};
            if (sectionCandidate is Map<String, dynamic>) {
              section = sectionCandidate;
            } else if (sectionCandidate is String) {
              try {
                final parsed = jsonDecode(sectionCandidate);
                if (parsed is Map<String, dynamic>) section = parsed;
              } catch (_) {
                // skip
              }
            }

            final title = section['section_title']?.toString() ?? '';
            final propsRaw = section['properties'] as List<dynamic>? ?? [];
            final props = propsRaw
                .whereType<Map<String, dynamic>>()
                .map((e) => Property.fromJson(e))
                .toList();
            sections[key] = {
              'section_title': title,
              'properties': props,
            };
          }
          return {'success': true, 'sections': sections};
        } else {
          // dataMap empty — return raw decoded for debugging
          return {'success': false, 'error': 'unexpected response shape', 'raw': decoded, 'sections': {}};
        }
      }
      return {'success': false, 'sections': {}};
    } catch (e) {
      // ignore: avoid_print
      print('❌ GET HOME SECTIONS ERROR: $e');
      return {'success': false, 'error': e.toString(), 'sections': {}};
    }
  }
}

