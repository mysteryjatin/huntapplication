import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/models/subscription_plans_models.dart';
import 'package:hunt_property/services/subscription_plans_service.dart';

abstract class SubscriptionPlansState extends Equatable {
  const SubscriptionPlansState();

  @override
  List<Object?> get props => [];
}

class SubscriptionPlansInitial extends SubscriptionPlansState {}

class SubscriptionPlansLoading extends SubscriptionPlansState {}

class SubscriptionPlansLoaded extends SubscriptionPlansState {
  final SubscriptionPlansResponse data;

  const SubscriptionPlansLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class SubscriptionPlansError extends SubscriptionPlansState {
  final String message;

  const SubscriptionPlansError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubscriptionPlansCubit extends Cubit<SubscriptionPlansState> {
  final SubscriptionPlansService _service;

  SubscriptionPlansCubit(this._service) : super(SubscriptionPlansInitial());

  Future<void> load({String? userId}) async {
    emit(SubscriptionPlansLoading());
    try {
      final data = await _service.getSubscriptionPlans(userId: userId);
      emit(SubscriptionPlansLoaded(data));
    } catch (e) {
      emit(SubscriptionPlansError(e.toString()));
    }
  }
}
