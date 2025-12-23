import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://72.61.237.178:8000';

  // Helper method to convert error detail to String
  String _getErrorMessage(dynamic detail, String defaultMessage) {
    if (detail == null) return defaultMessage;
    if (detail is String) return detail;
    if (detail is List) {
      // Handle validation errors that come as a list
      return detail.map((e) => e.toString()).join(', ');
    }
    return detail.toString();
  }

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('OTP API Response: $responseBody');
        print('OTP API Response Type: ${responseBody.runtimeType}');
        return {'success': true, 'data': responseBody};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'error': _getErrorMessage(body['detail'], 'Failed to request OTP')
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'error': _getErrorMessage(body['detail'], 'Invalid OTP')
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String userType,
    required bool termsAccepted,
  }) async {
    try {
      // Validate email format
      if (!email.contains('@') || !email.contains('.')) {
        return {
          'success': false,
          'error': 'Please enter a valid email address'
        };
      }
      
      final requestBody = {
        'full_name': name,  // API expects full_name, not name
        'email': email.trim(),  // Ensure email is trimmed
        'phone_number': phone,  // API expects phone_number, not phone
        'user_type': userType,
        'terms_accepted': termsAccepted,  // API requires terms_accepted
      };
      
      final jsonBody = jsonEncode(requestBody);
      
      print('=== SIGNUP REQUEST ===');
      print('Request Body Map: $requestBody');
      print('JSON Body: $jsonBody');
      print('Email being sent: "$email"');
      print('Email length: ${email.length}');
      print('Email contains @: ${email.contains('@')}');
      print('Email trimmed: "${email.trim()}"');
      print('Phone number: "$phone"');
      print('====================');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );
      
      print('=== SIGNUP RESPONSE ===');
      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('======================');
      
      // Parse response to check what email was actually saved
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Response Data: $responseData');
        
        // Check if email is in response
        if (responseData is Map) {
          if (!responseData.containsKey('email')) {
            print('⚠️ CRITICAL: API response does NOT include email field!');
            print('⚠️ Backend is likely auto-generating email from phone number.');
            print('⚠️ Email sent: "$email"');
            print('⚠️ This is a BACKEND BUG - the API is ignoring the email field.');
            print('⚠️ Backend needs to be fixed to accept and save the email field.');
          } else {
            final savedEmail = responseData['email'].toString();
            print('Email in response: "$savedEmail"');
            print('Email we sent: "$email"');
            print('Email matches sent: ${savedEmail == email.trim()}');
            
            // Check if backend generated temp email
            if (savedEmail.contains('@temp.huntproperty.com') && savedEmail != email.trim()) {
              print('⚠️ WARNING: Backend generated temp email instead of using provided email!');
              print('⚠️ This is a BACKEND ISSUE - the API is ignoring the email field.');
            }
          }
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'error': _getErrorMessage(body['detail'], 'Failed to signup')
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/check-phone/$phoneNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Login OTP methods
  Future<Map<String, dynamic>> loginRequestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Login OTP API Response: $responseBody');
        return {'success': true, 'data': responseBody};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'error': _getErrorMessage(body['detail'], 'Failed to request login OTP')
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginVerifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'error': _getErrorMessage(body['detail'], 'Invalid OTP')
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

