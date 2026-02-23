import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:hunt_property/models/property.dart';
import 'package:hunt_property/repositories/property_repository.dart';

part 'property_state.dart';

class PropertyCubit extends Cubit<PropertyState> {
  final PropertyRepository repository;

  PropertyCubit({required this.repository}) : super(PropertyInitial());

  Future<void> fetchProperty(String id) async {
    try {
      emit(PropertyLoading());
      final property = await repository.fetchProperty(id);
      emit(PropertyLoaded(property));
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }
}

