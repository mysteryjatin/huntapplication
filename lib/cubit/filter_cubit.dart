import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/models/filter_models.dart';
import 'package:hunt_property/services/filter_service.dart';

abstract class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object?> get props => [];
}

class FilterInitial extends FilterState {}

class FilterLoading extends FilterState {}

class FilterLoaded extends FilterState {
  final FilterScreenResponse data;

  const FilterLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class FilterError extends FilterState {
  final String message;

  const FilterError(this.message);

  @override
  List<Object?> get props => [message];
}

class FilterCubit extends Cubit<FilterState> {
  final FilterService _service;

  FilterCubit(this._service) : super(FilterInitial());

  Future<void> load({String? transactionType}) async {
    emit(FilterLoading());
    try {
      final data = await _service.getFilterScreen(transactionType: transactionType);
      emit(FilterLoaded(data));
    } catch (e) {
      emit(FilterError(e.toString()));
    }
  }
}

