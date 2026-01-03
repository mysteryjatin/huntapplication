import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpRequested extends AuthState {
  final String phone;
  final String? otp; // OTP for development/testing
  final bool isLogin; // Track if this is for login or signup

  const OtpRequested(this.phone, {this.otp, this.isLogin = false});

  @override
  List<Object?> get props => [phone, otp, isLogin];
}

class OtpVerified extends AuthState {
  final User? user;
  final bool phoneExists;

  const OtpVerified({this.user, required this.phoneExists});

  @override
  List<Object?> get props => [user, phoneExists];
}

class SignupRequired extends AuthState {
  final String phone;

  const SignupRequired(this.phone);

  @override
  List<Object?> get props => [phone];
}

class SignupSuccess extends AuthState {
  final User user;

  const SignupSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckPhoneEvent extends AuthEvent {
  final String phoneNumber;

  const CheckPhoneEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class RequestOtpEvent extends AuthEvent {
  final String phone;

  const RequestOtpEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtpEvent({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

class SignupEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String userType;

  const SignupEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
  });

  @override
  List<Object?> get props => [name, email, phone, userType];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> checkPhone(String phoneNumber) async {
    emit(AuthLoading());
    try {
      final exists = await _authService.checkPhoneExists(phoneNumber);
      if (exists) {
        // Phone exists, use login API
        await loginRequestOtp(phoneNumber);
      } else {
        // Phone doesn't exist, use signup OTP API for new user
        await requestOtp(phoneNumber);
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> requestOtp(String phone) async {
    emit(AuthLoading());
    try {
      final result = await _authService.requestOtp(phone);
      if (result['success']) {
        // Extract OTP from response if available (for development/testing)
        String? otp;
        final data = result['data'];
        
        // Debug: Print the response to see structure
        print('OTP Response data: $data');
        print('OTP Response data type: ${data.runtimeType}');
        
        if (data is Map) {
          // Try common OTP field names - handle both int and string types
          dynamic otpValue = data['otp'] ?? 
                data['code'] ?? 
                data['otp_code'] ?? 
                data['verification_code'] ??
                data['otpCode'] ??
                data['verificationCode'];
          
          // Convert to string if it's a number
          if (otpValue != null) {
            otp = otpValue.toString();
          }
          
          // If still no OTP found, check nested structures
          if (otp == null && data.containsKey('data')) {
            final nestedData = data['data'];
            if (nestedData is Map) {
              dynamic nestedOtp = nestedData['otp'] ?? nestedData['code'] ?? nestedData['otp_code'];
              if (nestedOtp != null) {
                otp = nestedOtp.toString();
              }
            }
          }
          
          // If OTP is in a message format, try to extract it
          if (otp == null) {
            final message = data['message']?.toString() ?? '';
            final otpMatch = RegExp(r'\b\d{4,6}\b').firstMatch(message);
            if (otpMatch != null) {
              otp = otpMatch.group(0);
            }
          }
        } else if (data is String) {
          // If data is directly a string, try to extract OTP from it
          final otpMatch = RegExp(r'\b\d{4,6}\b').firstMatch(data);
          if (otpMatch != null) {
            otp = otpMatch.group(0);
          } else {
            otp = data;
          }
        }
        
        print('Extracted OTP: $otp');
        
        // If OTP not found, try more aggressive extraction
        if (otp == null || otp.isEmpty) {
          print('OTP not found in response. Full data: $data');
          
          // Convert entire response to string and search for OTP patterns
          final responseStr = data.toString();
          print('Searching for OTP in: $responseStr');
          
          // Try to find 4-6 digit numbers (OTP patterns)
          final otpMatches = RegExp(r'\d{4,6}').allMatches(responseStr);
          for (final match in otpMatches) {
            final potentialOtp = match.group(0);
            // Prefer 6-digit OTPs, but accept 4-5 digit ones too
            if (potentialOtp != null && potentialOtp.length >= 4) {
              otp = potentialOtp;
              print('Found OTP pattern: $otp');
              break;
            }
          }
          
          // If still not found, try extracting from nested JSON strings
          if ((otp == null || otp.isEmpty) && data is Map) {
            // Check all string values in the map
            for (var value in data.values) {
              if (value is String) {
                final match = RegExp(r'\d{4,6}').firstMatch(value);
                if (match != null) {
                  otp = match.group(0);
                  print('Found OTP in string value: $otp');
                  break;
                }
              }
            }
          }
        }
        
        // Always emit with OTP (even if null, so we can debug)
        print('Final OTP to display: $otp');
        emit(OtpRequested(phone, otp: otp));
      } else {
        emit(AuthError(result['error'] ?? 'Failed to request OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String phone, String otp, {bool isLogin = false}) async {
    emit(AuthLoading());
    try {
      Map<String, dynamic> result;
      if (isLogin) {
        // Use login verify API
        result = await _authService.loginVerifyOtp(phone, otp);
      } else {
        // Use signup verify API
        result = await _authService.verifyOtp(phone, otp);
      }
      
      if (result['success']) {
        final responseData = result['data'];
        
        // Extract user data and token from response
        String? userId;
        String? token;
        
        if (responseData is Map) {
          // Try to extract user_id or id
          userId = responseData['user_id']?.toString() ?? 
                   responseData['id']?.toString() ?? 
                   responseData['_id']?.toString();
          
          // Try to extract token
          token = responseData['token']?.toString() ?? 
                  responseData['access_token']?.toString();
          
          // If user data is nested
          if (userId == null && responseData['user'] is Map) {
            final userData = responseData['user'];
            userId = userData['user_id']?.toString() ?? 
                     userData['id']?.toString() ?? 
                     userData['_id']?.toString();
          }
        }
        
        // Save user data to storage (with error handling)
        try {
          if (userId != null) {
            await StorageService.saveUserId(userId);
            await StorageService.saveUserPhone(phone);
          }
          if (token != null) {
            await StorageService.saveToken(token);
          }
          if (userId != null) {
            await StorageService.setLoggedIn(true);
          }
        } catch (e) {
          print('Error saving user data to storage: $e');
          // Continue even if storage fails - user can still proceed
        }
        
        if (isLogin) {
          // Login successful, navigate to home
          emit(OtpVerified(phoneExists: true));
        } else {
          // Check if phone exists after OTP verification (for signup flow)
          final phoneExists = await _authService.checkPhoneExists(phone);
          
          if (phoneExists) {
            // Phone exists, user is logged in
            emit(OtpVerified(phoneExists: true));
          } else {
            // Phone doesn't exist, need to signup
            emit(SignupRequired(phone));
          }
        }
      } else {
        emit(AuthError(result['error'] ?? 'Invalid OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginRequestOtp(String phone) async {
    emit(AuthLoading());
    try {
      final result = await _authService.loginRequestOtp(phone);
      if (result['success']) {
        // Extract OTP from response if available (for development/testing)
        String? otp;
        final data = result['data'];
        
        print('Login OTP Response data: $data');
        
        if (data is Map) {
          // Try common OTP field names - handle both int and string types
          dynamic otpValue = data['otp'] ?? 
                data['code'] ?? 
                data['otp_code'] ?? 
                data['verification_code'] ??
                data['otpCode'] ??
                data['verificationCode'];
          
          // Convert to string if it's a number
          if (otpValue != null) {
            otp = otpValue.toString();
          }
          
          // If still no OTP found, check nested structures
          if (otp == null && data.containsKey('data')) {
            final nestedData = data['data'];
            if (nestedData is Map) {
              dynamic nestedOtp = nestedData['otp'] ?? nestedData['code'] ?? nestedData['otp_code'];
              if (nestedOtp != null) {
                otp = nestedOtp.toString();
              }
            }
          }
          
          // If OTP is in a message format, try to extract it
          if (otp == null) {
            final message = data['message']?.toString() ?? '';
            final otpMatch = RegExp(r'\b\d{4,6}\b').firstMatch(message);
            if (otpMatch != null) {
              otp = otpMatch.group(0);
            }
          }
        } else if (data is String) {
          // If data is directly a string, try to extract OTP from it
          final otpMatch = RegExp(r'\b\d{4,6}\b').firstMatch(data);
          if (otpMatch != null) {
            otp = otpMatch.group(0);
          } else {
            otp = data;
          }
        }
        
        // If OTP not found, try more aggressive extraction
        if (otp == null || otp.isEmpty) {
          print('Login OTP not found in response. Full data: $data');
          final responseStr = data.toString();
          final otpMatches = RegExp(r'\d{4,6}').allMatches(responseStr);
          for (final match in otpMatches) {
            final potentialOtp = match.group(0);
            if (potentialOtp != null && potentialOtp.length >= 4) {
              otp = potentialOtp;
              print('Found Login OTP pattern: $otp');
              break;
            }
          }
        }
        
        print('Final Login OTP to display: $otp');
        emit(OtpRequested(phone, otp: otp, isLogin: true));
      } else {
        emit(AuthError(result['error'] ?? 'Failed to request login OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String phone,
    required String userType,
    required bool termsAccepted,
  }) async {
    print('🚀 Signup called: name=$name, email=$email, phone=$phone, userType=$userType');
    emit(AuthLoading());
    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        termsAccepted: termsAccepted,
      );
      print('📡 Signup API result: ${result['success']}');
      if (result['success']) {
        print('✅ Signup API call successful');
        final userData = result['data'];
        print('📦 User data from API: $userData');
        print('👤 User type from request: $userType');
        
        // Map response fields to User model (backend returns different field names)
        final mappedUserData = {
          '_id': userData['user_id'] ?? userData['_id'] ?? '',
          'name': userData['full_name'] ?? userData['name'] ?? '',
          'email': userData['email'] ?? '',
          'phone': userData['phone_number'] ?? userData['phone'] ?? phone,
          'user_type': userType, // Use the userType from request since backend might not return it
          'created_at': userData['created_at'] ?? DateTime.now().toIso8601String(),
        };
        
        print('🔄 Mapped user data: $mappedUserData');
        final user = User.fromJson(mappedUserData);
        print('👤 User object created: id=${user.id}, name=${user.name}, userType=${user.userType}');
        
        // Save user data to storage after signup (with error handling)
        try {
          if (user.id.isNotEmpty) {
            await StorageService.saveUserId(user.id);
            await StorageService.saveUserPhone(phone);
            await StorageService.setLoggedIn(true);
            await StorageService.saveUserType(userType); // Save user type
            print('💾 User data saved to storage');
            
            // Try to extract token if available
            if (userData is Map && userData['token'] != null) {
              await StorageService.saveToken(userData['token'].toString());
            }
          } else {
            print('⚠️ User ID is empty, skipping storage save');
          }
        } catch (e) {
          print('❌ Error saving user data to storage after signup: $e');
          // Continue even if storage fails - user can still proceed
        }
        
        print('🎉 Emitting SignupSuccess state');
        emit(SignupSuccess(user));
      } else {
        emit(AuthError(result['error'] ?? 'Failed to signup'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Check if user has an existing session and restore it
  /// This should be called on app startup to maintain login state
  Future<void> checkSession() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      final userId = await StorageService.getUserId();
      final token = await StorageService.getToken();
      
      // Check if we have valid session data
      if (isLoggedIn && userId != null && userId.isNotEmpty && userId != '000000000000000000000000') {
        // User has a valid session, emit authenticated state
        print('✅ Session found - User ID: $userId');
        emit(OtpVerified(phoneExists: true));
      } else {
        // No valid session found
        print('ℹ️ No valid session found');
        emit(AuthInitial());
      }
    } catch (e) {
      print('❌ Error checking session: $e');
      emit(AuthInitial());
    }
  }

  /// Logout user and clear session
  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      emit(AuthInitial());
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
      // Still emit initial state even if clearing storage fails
      emit(AuthInitial());
    }
  }
}

