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

  // Verify OTP for signup flow
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'otp': otp}),
      );

      print('📥 Verify OTP Response: ${response.statusCode} ${response.body}');

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
      print('❌ Verify OTP Error: $e');
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

  // Login verify OTP method
  Future<Map<String, dynamic>> loginVerifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'otp': otp}),
      );

      print('📥 Login Verify OTP Response: ${response.statusCode} ${response.body}');

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
      print('❌ Login Verify OTP Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Google Sign-In: Find or create user (no backend changes needed)
  Future<Map<String, dynamic>> googleSignIn({
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      print('🔍 Google Sign-In: Attempting to create/find user with email: $email');
      
      // Generate a unique phone number from email for Google users
      // Format: +91 followed by hash of email (first 10 digits)
      final emailHash = email.hashCode.abs().toString();
      final phoneNumber = '+91${emailHash.padLeft(10, '0').substring(0, 10)}';
      
      // Try to create user directly via users endpoint
      // If user already exists, we'll handle the error
      final createResponse = await http.post(
        Uri.parse('$baseUrl/api/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email.trim(),
          'phone': phoneNumber,
          'user_type': 'buyer',
          'password': emailHash, // Use email hash as password for Google users
        }),
      );

      print('📥 Google Sign-In Create Response: ${createResponse.statusCode}');
      print('📥 Google Sign-In Response Body: ${createResponse.body}');

      if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
        // User created successfully
        final userData = jsonDecode(createResponse.body);
        print('✅ Google Sign-In: User created successfully');
        print('   User Data: $userData');
        
        final userId = userData['_id']?.toString() ?? userData['id']?.toString();
        if (userId == null || userId.isEmpty) {
          print('❌ Google Sign-In: User ID is null or empty');
          return {
            'success': false,
            'error': 'User created but user ID not found in response',
          };
        }
        
        return {
          'success': true,
          'data': {
            'user_id': userId,
            'email': userData['email']?.toString() ?? email,
            'name': userData['name']?.toString() ?? name,
            'phone': userData['phone']?.toString() ?? phoneNumber,
            'user_type': userData['user_type']?.toString() ?? 'buyer',
          },
        };
      } else {
        // User creation failed - likely because email already exists
        String errorMessage = 'Failed to create user';
        try {
          final errorBody = jsonDecode(createResponse.body);
          errorMessage = errorBody['detail']?.toString() ?? errorBody['message']?.toString() ?? 'Failed to create user';
        } catch (_) {
          errorMessage = createResponse.body;
        }
        
        print('⚠️ Google Sign-In: User creation failed: $errorMessage');
        
        // If email already exists, query users to find the existing user
        if (errorMessage.toLowerCase().contains('already registered') || 
            errorMessage.toLowerCase().contains('already exists') ||
            errorMessage.toLowerCase().contains('email')) {
          print('🔄 Google Sign-In: Email exists, querying users to find existing user...');
          
          // Query users endpoint with pagination to find the existing user by email
          // Backend has max limit of 100, so we'll paginate through results
          int skip = 0;
          const int limit = 100; // Max allowed by backend
          const int maxPages = 10; // Safety limit: max 1000 users to search
          bool found = false;
          Map<String, dynamic>? foundUser;
          int pageCount = 0;
          
          while (!found && pageCount < maxPages) {
            pageCount++;
            final usersResponse = await http.get(
              Uri.parse('$baseUrl/api/users/?skip=$skip&limit=$limit'),
              headers: {'Content-Type': 'application/json'},
            );
            
            print('📥 Google Sign-In Users Query Response: ${usersResponse.statusCode} (skip=$skip, limit=$limit, page=$pageCount)');
            
            if (usersResponse.statusCode == 200) {
              try {
                final List<dynamic> users = jsonDecode(usersResponse.body);
                print('📊 Google Sign-In: Found ${users.length} users in this batch');
                
                if (users.isEmpty) {
                  // No more users to check
                  print('📊 Google Sign-In: No more users to check');
                  break;
                }
                
                // Search for user with matching email
                try {
                  final user = users.firstWhere(
                    (u) => u['email']?.toString().toLowerCase() == email.toLowerCase(),
                  );
                  
                  foundUser = user as Map<String, dynamic>;
                  found = true;
                  print('✅ Google Sign-In: Found existing user in batch (page $pageCount)');
                  break;
                } catch (_) {
                  // User not in this batch, continue to next page
                  if (users.length < limit) {
                    // Last page, user not found
                    print('📊 Google Sign-In: Reached last page, user not found');
                    break;
                  }
                  skip += limit;
                }
              } catch (e) {
                print('❌ Google Sign-In: Error parsing users response: $e');
                break;
              }
            } else {
              print('❌ Google Sign-In: Failed to query users: ${usersResponse.statusCode}');
              print('   Response body: ${usersResponse.body}');
              break;
            }
          }
          
          if (pageCount >= maxPages) {
            print('⚠️ Google Sign-In: Reached max pages limit ($maxPages), stopping search');
          }
          
          if (found && foundUser != null) {
            final userId = foundUser['_id']?.toString() ?? foundUser['id']?.toString();
            print('✅ Google Sign-In: Found existing user with ID: $userId');
            
            return {
              'success': true,
              'data': {
                'user_id': userId,
                'email': foundUser['email']?.toString() ?? email,
                'name': foundUser['name']?.toString() ?? name,
                'phone': foundUser['phone']?.toString() ?? phoneNumber,
                'user_type': foundUser['user_type']?.toString() ?? 'buyer',
              },
            };
          } else {
            print('❌ Google Sign-In: User not found in users list after searching');
            return {
              'success': false,
              'error': 'User exists but could not be retrieved from database',
            };
          }
        }
        
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Google Sign-In Error: $e');
      print('❌ Stack Trace: $stackTrace');
      return {'success': false, 'error': e.toString()};
    }
  }
}

