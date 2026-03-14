part of 'property_cubit.dart';

@immutable
abstract class PropertyState {}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertyLoaded extends PropertyState {
  final Property property;
  PropertyLoaded(this.property);
}

class PropertyError extends PropertyState {
  final String message;
  PropertyError(this.message);
}

