import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/models/property_models.dart';

class PropertyService {
  // Re‑use the same base URL as auth
  static const String baseUrl = AuthService.baseUrl;

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

  Future<List<Property>> getProperties() async {
    try {
      // Matching the backend route with trailing slash: GET /api/properties/
      final uri = Uri.parse('$baseUrl/api/properties/');

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
}

