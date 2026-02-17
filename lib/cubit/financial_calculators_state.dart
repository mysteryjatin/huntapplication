import 'package:equatable/equatable.dart';
import '../data/models/loan_eligibility_model.dart';
import '../data/models/rental_value_model.dart';
import '../data/models/emi_model.dart';

enum CalcStatus { initial, loading, success, failure }

class FinancialCalculatorsState extends Equatable {
  final CalcStatus status;
  final LoanEligibilityModel? loanEligibility;
  final RentalValueModel? rentalValue;
  final EmiModel? emi;
  final Map<String, dynamic>? futureValue;
  final String? error;

  const FinancialCalculatorsState({
    this.status = CalcStatus.initial,
    this.loanEligibility,
    this.rentalValue,
    this.emi,
    this.futureValue,
    this.error,
  });

  FinancialCalculatorsState copyWith({
    CalcStatus? status,
    LoanEligibilityModel? loanEligibility,
    RentalValueModel? rentalValue,
    EmiModel? emi,
    Map<String, dynamic>? futureValue,
    String? error,
  }) {
    return FinancialCalculatorsState(
      status: status ?? this.status,
      loanEligibility: loanEligibility ?? this.loanEligibility,
      rentalValue: rentalValue ?? this.rentalValue,
      emi: emi ?? this.emi,
      futureValue: futureValue ?? this.futureValue,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, loanEligibility, rentalValue, emi, futureValue, error];
}

