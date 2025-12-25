import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/services/storage_service.dart';

class ProfileService {
  static const String baseUrl = AuthService.baseUrl;

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET profile by user_id
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile/$userId'),
        headers: headers,
      );

      print('📥 GET PROFILE RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        String errorMessage = 'Failed to get profile';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['detail'] != null) {
            errorMessage = body['detail'].toString();
          }
        } catch (_) {
          // ignore JSON parse error
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ GET PROFILE ERROR: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // PUT/Update profile by user_id
  Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/profile/$userId'),
        headers: headers,
        body: jsonEncode(profileData),
      );

      print('📤 UPDATE PROFILE REQUEST: $profileData');
      print('📥 UPDATE PROFILE RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        String errorMessage = 'Failed to update profile';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['detail'] != null) {
            errorMessage = body['detail'].toString();
          }
        } catch (_) {
          // ignore JSON parse error
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ UPDATE PROFILE ERROR: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}


