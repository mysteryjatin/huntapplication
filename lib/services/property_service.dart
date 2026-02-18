import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/models/property_models.dart';

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
}

