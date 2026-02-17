import 'package:equatable/equatable.dart';
import '../data/models/agent_model.dart';

enum AgentsStatus { initial, loading, success, failure }

class AgentsState extends Equatable {
  final AgentsStatus status;
  final List<AgentModel> agents;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;
  final bool? hasNext;
  final bool? hasPrev;
  final String? error;

  const AgentsState({
    this.status = AgentsStatus.initial,
    this.agents = const [],
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
    this.error,
  });

  AgentsState copyWith({
    AgentsStatus? status,
    List<AgentModel>? agents,
    int? total,
    int? page,
    int? limit,
    int? totalPages,
    bool? hasNext,
    bool? hasPrev,
    String? error,
  }) {
    return AgentsState(
      status: status ?? this.status,
      agents: agents ?? this.agents,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrev: hasPrev ?? this.hasPrev,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, agents, total, page, limit, totalPages, hasNext, hasPrev, error];
}

