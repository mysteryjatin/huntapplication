import 'package:bloc/bloc.dart';
import '../data/repository/nri_repository.dart';
import 'nri_state.dart';

class NriCubit extends Cubit<NriState> {
  final NriRepository repository;
  NriCubit({required this.repository}) : super(const NriState());

  Future<void> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String stateName,
    required String country,
    required String message,
    String? userId,
  }) async {
    emit(this.state.copyWith(status: NriStatus.submitting));
    try {
      final res = await repository.submitQuery(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        stateName: stateName,
        country: country,
        message: message,
        userId: userId,
      );
      emit(this.state.copyWith(status: NriStatus.success, query: res));
    } catch (e) {
      emit(this.state.copyWith(status: NriStatus.failure, error: e.toString()));
    }
  }
}

