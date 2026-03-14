class AgentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String dealingIn;
  final String operatingSince;
  final String userType;
  final String createdAt;

  AgentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.dealingIn,
    required this.operatingSince,
    required this.userType,
    required this.createdAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      dealingIn: json['dealing_in'] as String? ?? '',
      operatingSince: json['operating_since'] as String? ?? '',
      userType: json['user_type'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

