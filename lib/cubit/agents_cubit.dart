import 'package:bloc/bloc.dart';
import '../data/repository/agents_repository.dart';
import 'agents_state.dart';

class AgentsCubit extends Cubit<AgentsState> {
  final AgentsRepository repository;

  AgentsCubit({required this.repository}) : super(const AgentsState());

  /// Search agents with optional filters. Emits loading -> success/failure.
  Future<void> search({Map<String, dynamic>? filters}) async {
    emit(state.copyWith(status: AgentsStatus.loading));
    try {
      final res = await repository.search(payload: filters);
      final agents = res['agents'] as List;
      emit(state.copyWith(
        status: AgentsStatus.success,
        agents: List.from(agents),
        total: res['total'] as int?,
        page: res['page'] as int?,
        limit: res['limit'] as int?,
        totalPages: res['total_pages'] as int?,
        hasNext: res['has_next'] as bool?,
        hasPrev: res['has_prev'] as bool?,
      ));
    } catch (e) {
      emit(state.copyWith(status: AgentsStatus.failure, error: e.toString()));
    }
  }
}

