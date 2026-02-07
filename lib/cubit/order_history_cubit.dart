import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/models/order_history_models.dart';
import 'package:hunt_property/services/order_history_service.dart';

abstract class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object?> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderItem> orders;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;
  final String status;

  const OrderHistoryLoaded({
    required this.orders,
    required this.page,
    required this.hasNext,
    required this.status,
    this.isLoadingMore = false,
  });

  OrderHistoryLoaded copyWith({
    List<OrderItem>? orders,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    String? status,
  }) {
    return OrderHistoryLoaded(
      orders: orders ?? this.orders,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      status: status ?? this.status,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [orders, page, hasNext, isLoadingMore, status];
}

class OrderHistoryError extends OrderHistoryState {
  final String message;

  const OrderHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final OrderHistoryService _service;
  String _currentStatus = 'all';

  OrderHistoryCubit(this._service) : super(OrderHistoryInitial());

  String get currentStatus => _currentStatus;

  Future<void> load({String status = 'all'}) async {
    _currentStatus = status;
    emit(OrderHistoryLoading());
    try {
      final res = await _service.getOrderHistory(
        status: status,
        page: 1,
      );
      emit(
        OrderHistoryLoaded(
          orders: res.orders,
          page: res.page,
          hasNext: res.hasNext,
          status: status,
        ),
      );
    } catch (e) {
      emit(OrderHistoryError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! OrderHistoryLoaded) return;
    if (current.isLoadingMore || !current.hasNext) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.page + 1;
      final res = await _service.getOrderHistory(
        status: current.status,
        page: nextPage,
      );

      final combined = List<OrderItem>.from(current.orders)
        ..addAll(res.orders);

      emit(
        current.copyWith(
          orders: combined,
          page: res.page,
          hasNext: res.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
