import 'package:equatable/equatable.dart';
import '../data/models/nri_query_model.dart';

enum NriStatus { initial, submitting, success, failure }

class NriState extends Equatable {
  final NriStatus status;
  final NriQueryModel? query;
  final String? error;

  const NriState({this.status = NriStatus.initial, this.query, this.error});

  NriState copyWith({NriStatus? status, NriQueryModel? query, String? error}) {
    return NriState(
      status: status ?? this.status,
      query: query ?? this.query,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, query, error];
}

