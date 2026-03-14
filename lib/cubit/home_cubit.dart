import 'package:bloc/bloc.dart';
import 'package:hunt_property/repositories/home_repository.dart';
import 'package:hunt_property/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repo;
  HomeCubit(this.repo) : super(HomeInitial());

  Future<void> fetchHome({
    String city = 'Chennai',
    String? userId,
    int limit = 10,
    String? transactionType,
    String? propertyCategory,
  }) async {
    emit(HomeLoading());
    try {
      final data = await repo.fetchHomeSections(
        city: city,
        userId: userId,
        limit: limit,
        transactionType: transactionType,
        propertyCategory: propertyCategory,
      );
      emit(HomeLoaded(data));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  /// Backwards-compatible helper to call fetchHome with filter params.
  Future<void> fetchHomeWithFilters({
    String city = 'Chennai',
    String? userId,
    int limit = 10,
    String? transactionType,
    String? propertyCategory,
  }) async {
    await fetchHome(
      city: city,
      userId: userId,
      limit: limit,
      transactionType: transactionType,
      propertyCategory: propertyCategory,
    );
  }
}

