class EmiModel {
  final int monthlyEmi;
  final int totalAmountPayable;
  final int totalInterest;
  final int loanAmount;
  final int loanTenureYears;
  final num rateOfInterest;

  EmiModel({
    required this.monthlyEmi,
    required this.totalAmountPayable,
    required this.totalInterest,
    required this.loanAmount,
    required this.loanTenureYears,
    required this.rateOfInterest,
  });

  factory EmiModel.fromJson(Map<String, dynamic> json) {
    return EmiModel(
      monthlyEmi: (json['monthly_emi'] as num).toInt(),
      totalAmountPayable: (json['total_amount_payable'] as num).toInt(),
      totalInterest: (json['total_interest'] as num).toInt(),
      loanAmount: (json['loan_amount'] as num).toInt(),
      loanTenureYears: (json['loan_tenure_years'] as num).toInt(),
      rateOfInterest: json['rate_of_interest'] as num,
    );
  }
}

