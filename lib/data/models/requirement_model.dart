class RequirementModel {
  final String id;
  final String iam;
  final String want;
  final String name;
  final String email;
  final String mobile;
  final String propertyType;
  final String propertyCity;
  final String bhk;
  final num minPrice;
  final num maxPrice;
  final String status;
  final String createdAt;

  RequirementModel({
    required this.id,
    required this.iam,
    required this.want,
    required this.name,
    required this.email,
    required this.mobile,
    required this.propertyType,
    required this.propertyCity,
    required this.bhk,
    required this.minPrice,
    required this.maxPrice,
    required this.status,
    required this.createdAt,
  });

  factory RequirementModel.fromJson(Map<String, dynamic> json) {
    return RequirementModel(
      id: json['_id'] as String,
      iam: json['iam'] as String,
      want: json['want'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      propertyType: json['property_type'] as String,
      propertyCity: json['property_city'] as String,
      bhk: json['bhk'] as String,
      minPrice: json['min_price'] as num,
      maxPrice: json['max_price'] as num,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

