import 'package:equatable/equatable.dart';
import '../data/models/requirement_model.dart';

enum RequirementStatus { initial, submitting, success, failure }

class RequirementState extends Equatable {
  final RequirementStatus status;
  final RequirementModel? requirement;
  final String? error;

  const RequirementState({this.status = RequirementStatus.initial, this.requirement, this.error});

  RequirementState copyWith({
    RequirementStatus? status,
    RequirementModel? requirement,
    String? error,
  }) {
    return RequirementState(
      status: status ?? this.status,
      requirement: requirement ?? this.requirement,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, requirement, error];
}

