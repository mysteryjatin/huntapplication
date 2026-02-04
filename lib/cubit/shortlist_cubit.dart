import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:hunt_property/models/shortlist_models.dart';
import 'package:hunt_property/services/shortlist_service.dart';

abstract class ShortlistState extends Equatable {
  const ShortlistState();

  @override
  List<Object?> get props => [];
}

class ShortlistInitial extends ShortlistState {}

class ShortlistLoading extends ShortlistState {}

class ShortlistLoaded extends ShortlistState {
  final List<Property> properties;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  const ShortlistLoaded({
    required this.properties,
    required this.page,
    required this.hasNext,
    this.isLoadingMore = false,
  });

  ShortlistLoaded copyWith({
    List<Property>? properties,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return ShortlistLoaded(
      properties: properties ?? this.properties,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [properties, page, hasNext, isLoadingMore];
}

class ShortlistError extends ShortlistState {
  final String message;

  const ShortlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShortlistCubit extends Cubit<ShortlistState> {
  final ShortlistService _service;
  final String? _transactionType;

  ShortlistCubit(this._service, {String? transactionType})
      : _transactionType = transactionType,
        super(ShortlistInitial());

  /// Initial load (page 1)
  Future<void> load() async {
    emit(ShortlistLoading());
    try {
      final ShortlistResponse res = await _service.getShortlist(
        transactionType: _transactionType,
        page: 1,
      );
      emit(
        ShortlistLoaded(
          properties: res.properties,
          page: res.page,
          hasNext: res.hasNext,
        ),
      );
    } catch (e) {
      emit(ShortlistError(e.toString()));
    }
  }

  /// Load next page and append to existing list.
  Future<void> loadMore() async {
    final current = state;
    if (current is! ShortlistLoaded) return;
    if (current.isLoadingMore || !current.hasNext) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.page + 1;
      final ShortlistResponse res = await _service.getShortlist(
        transactionType: _transactionType,
        page: nextPage,
      );

      final combined = List<Property>.from(current.properties)
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
      // In case of load-more error, keep old data but log error.
      // ignore: avoid_print
      print('❌ SHORTLIST LOAD MORE ERROR: $e');
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}

