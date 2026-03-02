import 'package:bloc/bloc.dart';
import '../data/repository/financial_calculators_repository.dart';
import 'financial_calculators_state.dart';

class FinancialCalculatorsCubit extends Cubit<FinancialCalculatorsState> {
  final FinancialCalculatorsRepository repository;

  FinancialCalculatorsCubit({required this.repository}) : super(const FinancialCalculatorsState());

  Future<void> checkLoanEligibility({
    required int loanRequired,
    required int netIncomePerMonth,
    required int existingLoanCommitments,
    required num loanTenureYears,
    required num rateOfInterest,
  }) async {
    emit(state.copyWith(status: CalcStatus.loading, error: null));
    try {
      final res = await repository.loanEligibility(
        loanRequired: loanRequired,
        netIncomePerMonth: netIncomePerMonth,
        existingLoanCommitments: existingLoanCommitments,
        loanTenureYears: loanTenureYears,
        rateOfInterest: rateOfInterest,
      );
      emit(state.copyWith(
        status: CalcStatus.success,
        loanEligibility: res,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: CalcStatus.failure, error: e.toString()));
    }
  }

  Future<void> checkRentalValue({
    required int propertyValue,
    required num rateOfRent,
    required int years,
  }) async {
    emit(state.copyWith(status: CalcStatus.loading, error: null));
    try {
      final res = await repository.rentalValue(
        propertyValue: propertyValue,
        rateOfRent: rateOfRent,
        years: years,
      );
      emit(state.copyWith(
        status: CalcStatus.success,
        rentalValue: res,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: CalcStatus.failure, error: e.toString()));
    }
  }

  Future<void> checkEmi({
    required int loanAmount,
    required int loanTenureYears,
    required num rateOfInterest,
  }) async {
    emit(state.copyWith(status: CalcStatus.loading, error: null));
    try {
      final res = await repository.emi(
        loanAmount: loanAmount,
        loanTenureYears: loanTenureYears,
        rateOfInterest: rateOfInterest,
      );
      emit(state.copyWith(
        status: CalcStatus.success,
        emi: res,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: CalcStatus.failure, error: e.toString()));
    }
  }

  Future<void> checkFutureValue(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: CalcStatus.loading, error: null));
    try {
      final res = await repository.futureValue(payload);
      emit(state.copyWith(
        status: CalcStatus.success,
        futureValue: res,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: CalcStatus.failure, error: e.toString()));
    }
  }

  /// Reset all computed results and return to initial state.
  void resetAll() {
    emit(const FinancialCalculatorsState());
  }
}

