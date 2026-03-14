class HomeLoanApplicationModel {
  final String id;
  final String userId;
  final String loanType;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String createdAt;

  HomeLoanApplicationModel({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  factory HomeLoanApplicationModel.fromJson(Map<String, dynamic> json) {
    return HomeLoanApplicationModel(
      id: json['_id'] as String,
      userId: json['user_id'] as String,
      loanType: json['loan_type'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

