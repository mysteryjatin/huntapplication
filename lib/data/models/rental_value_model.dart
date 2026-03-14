class RentalValueModel {
  final int rentalValueAnnual;
  final int rentalValueMonthly;
  final int propertyValue;
  final num rateOfRent;

  RentalValueModel({
    required this.rentalValueAnnual,
    required this.rentalValueMonthly,
    required this.propertyValue,
    required this.rateOfRent,
  });

  factory RentalValueModel.fromJson(Map<String, dynamic> json) {
    return RentalValueModel(
      rentalValueAnnual: (json['rental_value_annual'] as num).toInt(),
      rentalValueMonthly: (json['rental_value_monthly'] as num).toInt(),
      propertyValue: (json['property_value'] as num).toInt(),
      rateOfRent: json['rate_of_rent'] as num,
    );
  }
}

