class NriQueryModel {
  final String id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String state;
  final String country;
  final String message;
  final String createdAt;

  NriQueryModel({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.state,
    required this.country,
    required this.message,
    required this.createdAt,
  });

  factory NriQueryModel.fromJson(Map<String, dynamic> json) {
    return NriQueryModel(
      id: json['_id'] as String,
      userId: json['user_id'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      message: json['message'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

