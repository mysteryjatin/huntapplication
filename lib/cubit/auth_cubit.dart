import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

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
    emit(AuthLoading());
    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        termsAccepted: termsAccepted,
      );
      if (result['success']) {
        final userData = result['data'];
        final user = User.fromJson(userData);
        emit(SignupSuccess(user));
      } else {
        emit(AuthError(result['error'] ?? 'Failed to signup'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

