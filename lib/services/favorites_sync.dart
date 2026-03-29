import 'package:flutter/foundation.dart';

/// Bumps when shortlist/favorites change so Home, Search, etc. can reload IDs from the API.
class FavoritesSync {
  FavoritesSync._();

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void notifyChanged() {
    revision.value++;
  }
}
