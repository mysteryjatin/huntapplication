class RequestOtpRequest {
  final String phone;

  RequestOtpRequest({required this.phone});

  Map<String, dynamic> toJson() => {
        'phone': phone,
      };
}

class VerifyOtpRequest {
  final String phone;
  final String otp;

  VerifyOtpRequest({required this.phone, required this.otp});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };
}

class SignupRequest {
  final String name;
  final String email;
  final String phone;
  final String userType;

  SignupRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'user_type': userType,
      };
}

class User {
  final String name;
  final String email;
  final String phone;
  final String userType;
  final String id;
  final DateTime createdAt;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.id,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? '',
      id: json['_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'user_type': userType,
        '_id': id,
        'created_at': createdAt.toIso8601String(),
      };
}

class CheckPhoneResponse {
  final bool exists;

  CheckPhoneResponse({required this.exists});

  factory CheckPhoneResponse.fromJson(Map<String, dynamic> json) {
    return CheckPhoneResponse(
      exists: json['exists'] ?? false,
    );
  }
}


