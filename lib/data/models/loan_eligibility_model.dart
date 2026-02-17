class LoanEligibilityModel {
  final bool eligible;
  final String message;
  final int maximumEligibleAmount;
  final int maximumEmi;
  final int loanRequired;

  LoanEligibilityModel({
    required this.eligible,
    required this.message,
    required this.maximumEligibleAmount,
    required this.maximumEmi,
    required this.loanRequired,
  });

  factory LoanEligibilityModel.fromJson(Map<String, dynamic> json) {
    return LoanEligibilityModel(
      eligible: json['eligible'] as bool,
      message: json['message'] as String,
      maximumEligibleAmount: (json['maximum_eligible_amount'] as num).toInt(),
      maximumEmi: (json['maximum_emi'] as num).toInt(),
      loanRequired: (json['loan_required'] as num).toInt(),
    );
  }
}

