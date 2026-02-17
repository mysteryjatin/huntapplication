import 'package:bloc/bloc.dart';
import '../data/repository/home_loan_repository.dart';
import 'home_loan_state.dart';

class HomeLoanCubit extends Cubit<HomeLoanState> {
  final HomeLoanRepository repository;

  HomeLoanCubit({required this.repository}) : super(const HomeLoanState());

  Future<void> submit({
    required String loanType,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String userId,
  }) async {
    emit(state.copyWith(status: HomeLoanStatus.submitting));
    try {
      final app = await repository.submitApplication(
        loanType: loanType,
        name: name,
        email: email,
        phone: phone,
        address: address,
        userId: userId,
      );
      emit(state.copyWith(status: HomeLoanStatus.success, application: app));
    } catch (e) {
      emit(state.copyWith(status: HomeLoanStatus.failure, error: e.toString()));
    }
  }
}

