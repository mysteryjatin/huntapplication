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
    this.loanRequired = 0,
  });

  factory LoanEligibilityModel.fromJson(Map<String, dynamic> json) {
    return LoanEligibilityModel(
      eligible: json['eligible'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      maximumEligibleAmount: _toInt(json['maximum_eligible_amount']),
      maximumEmi: _toInt(json['maximum_emi']),
      loanRequired: _toInt(json['loan_required']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

