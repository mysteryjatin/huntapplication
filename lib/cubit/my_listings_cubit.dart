import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/models/my_listings_models.dart';
import 'package:hunt_property/services/my_listings_service.dart';

abstract class MyListingsState extends Equatable {
  const MyListingsState();

  @override
  List<Object?> get props => [];
}

class MyListingsInitial extends MyListingsState {}

class MyListingsLoading extends MyListingsState {}

class MyListingsLoaded extends MyListingsState {
  final List<MyListingItem> properties;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;
  final String status;

  const MyListingsLoaded({
    required this.properties,
    required this.page,
    required this.hasNext,
    required this.status,
    this.isLoadingMore = false,
  });

  MyListingsLoaded copyWith({
    List<MyListingItem>? properties,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    String? status,
  }) {
    return MyListingsLoaded(
      properties: properties ?? this.properties,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      status: status ?? this.status,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [properties, page, hasNext, isLoadingMore, status];
}

class MyListingsError extends MyListingsState {
  final String message;

  const MyListingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class MyListingsCubit extends Cubit<MyListingsState> {
  final MyListingsService _service;
  String _currentStatus = 'all';

  MyListingsCubit(this._service) : super(MyListingsInitial());

  String get currentStatus => _currentStatus;

  Future<void> load({String status = 'all'}) async {
    _currentStatus = status;
    emit(MyListingsLoading());
    try {
      final res = await _service.getMyListings(
        status: status,
        page: 1,
      );
      emit(
        MyListingsLoaded(
          properties: res.properties,
          page: res.page,
          hasNext: res.hasNext,
          status: status,
        ),
      );
    } catch (e) {
      emit(MyListingsError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! MyListingsLoaded) return;
    if (current.isLoadingMore || !current.hasNext) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.page + 1;
      final res = await _service.getMyListings(
        status: current.status,
        page: nextPage,
      );

      final combined = List<MyListingItem>.from(current.properties)
        ..addAll(res.properties);

      emit(
        current.copyWith(
          properties: combined,
          page: res.page,
          hasNext: res.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ MY LISTINGS LOAD MORE ERROR: $e');
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}

