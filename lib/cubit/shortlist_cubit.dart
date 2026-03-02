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

  /// App-session level cache of properties that user ne shortlist se hata diye hain.
  /// Isse kya hoga: agar backend remove API abhi sahi kaam nahi bhi kar rahi,
  /// to bhi current app session me woh properties dobara shortlist me show nahi hongi.
  static final Set<String> _sessionRemovedIds = {};

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

      // Filter out session-removed properties
      final filtered = res.properties
          .where((p) => !_sessionRemovedIds.contains(p.id))
          .toList();

      emit(
        ShortlistLoaded(
          properties: filtered,
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

      final pageFiltered = res.properties
          .where((p) => !_sessionRemovedIds.contains(p.id))
          .toList();

      final combined = List<Property>.from(current.properties)
        ..addAll(pageFiltered);

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

  /// Remove a single property from the shortlist (both locally and on server).
  /// UI me turant list se item hata diya jayega (optimistic update).
  Future<void> removeProperty(String propertyId) async {
    final current = state;
    if (current is! ShortlistLoaded) return;
    if (propertyId.isEmpty) return;

    // Optimistic local update – remove from current list
    final updated = List<Property>.from(current.properties)
      ..removeWhere((p) => p.id == propertyId);
    emit(current.copyWith(properties: updated));

    // Mark as removed for the rest of the app session, so agar Shortlist
    // dobara load ho bhi, to ye property filter ho jaaye.
    _sessionRemovedIds.add(propertyId);

    // Backend se bhi shortlist se hatao; agar API fail ho jaye to
    // current session me list waise hi trimmed rahegi.
    // (Fresh reload/visit par server se latest shortlist aa jayegi.)
    final ok = await _service.removeFromShortlist(propertyId);
    if (!ok) {
      // ignore failure for now – future me exact API path ke hisaab se
      // yahan better error handling add kiya ja sakta hai.
    }
  }
}

