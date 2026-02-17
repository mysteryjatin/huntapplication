import 'package:bloc/bloc.dart';
import '../data/repository/requirement_repository.dart';
import 'requirement_state.dart';

class RequirementCubit extends Cubit<RequirementState> {
  final RequirementRepository repository;
  RequirementCubit({required this.repository}) : super(const RequirementState());

  Future<void> submit({
    required String iam,
    required String want,
    required String name,
    required String email,
    required String mobile,
    required String propertyType,
    required String propertyCity,
    required String bhk,
    required num minPrice,
    required num maxPrice,
  }) async {
    emit(state.copyWith(status: RequirementStatus.submitting));
    try {
      final res = await repository.submitRequirement(
        iam: iam,
        want: want,
        name: name,
        email: email,
        mobile: mobile,
        propertyType: propertyType,
        propertyCity: propertyCity,
        bhk: bhk,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      emit(state.copyWith(status: RequirementStatus.success, requirement: res));
    } catch (e) {
      emit(state.copyWith(status: RequirementStatus.failure, error: e.toString()));
    }
  }
}

