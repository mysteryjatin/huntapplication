import 'package:equatable/equatable.dart';
import '../data/models/home_loan_application_model.dart';

enum HomeLoanStatus { initial, submitting, success, failure }

class HomeLoanState extends Equatable {
  final HomeLoanStatus status;
  final HomeLoanApplicationModel? application;
  final String? error;

  const HomeLoanState({this.status = HomeLoanStatus.initial, this.application, this.error});

  HomeLoanState copyWith({
    HomeLoanStatus? status,
    HomeLoanApplicationModel? application,
    String? error,
  }) {
    return HomeLoanState(
      status: status ?? this.status,
      application: application ?? this.application,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, application, error];
}

