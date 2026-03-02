class FilterLocality {
  final String value;
  final String city;

  const FilterLocality({required this.value, required this.city});

  factory FilterLocality.fromJson(Map<String, dynamic> json) {
    return FilterLocality(
      value: json['value']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
    );
  }
}

class FilterRange {
  final num min;
  final num max;

  const FilterRange({required this.min, required this.max});

  factory FilterRange.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

    return FilterRange(
      min: toNum(json['min']),
      max: toNum(json['max']),
    );
  }
}

class FilterScreenResponse {
  final List<String> transactionTypes;
  final List<String> propertyCategories;
  final List<String> propertySubtypes;
  final List<String> furnishingOptions;
  final List<String> facingOptions;
  final List<String> cities;
  final List<FilterLocality> localities;
  final FilterRange priceRange;
  final FilterRange areaRange;
  final List<int> bedrooms;
  final List<int> bathrooms;
  final List<bool> storeRoomOptions;
  final List<bool> servantRoomOptions;
  final List<Map<String, String>> possessionStatusOptions;
  final List<Map<String, dynamic>> availabilityMonths;
  final List<int> availabilityYears;
  final List<Map<String, String>> ageOfConstructionOptions;

  const FilterScreenResponse({
    required this.transactionTypes,
    required this.propertyCategories,
    required this.propertySubtypes,
    required this.furnishingOptions,
    required this.facingOptions,
    required this.cities,
    required this.localities,
    required this.priceRange,
    required this.areaRange,
    required this.bedrooms,
    required this.bathrooms,
    required this.storeRoomOptions,
    required this.servantRoomOptions,
    required this.possessionStatusOptions,
    required this.availabilityMonths,
    required this.availabilityYears,
    required this.ageOfConstructionOptions,
  });

  static List<String> _toStringList(dynamic v) {
    final list = (v as List<dynamic>? ?? const []);
    return list.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  static List<int> _toIntList(dynamic v) {
    final list = (v as List<dynamic>? ?? const []);
    int toInt(dynamic x) {
      if (x == null) return 0;
      if (x is int) return x;
      if (x is num) return x.toInt();
      if (x is String) return int.tryParse(x) ?? 0;
      return 0;
    }

    return list.map(toInt).toList();
  }

  static List<bool> _toBoolList(dynamic v) {
    final list = (v as List<dynamic>? ?? const []);
    bool toBool(dynamic x) {
      if (x is bool) return x;
      if (x is String) return x.toLowerCase() == 'true';
      if (x is num) return x != 0;
      return false;
    }

    return list.map(toBool).toList();
  }

  factory FilterScreenResponse.fromJson(Map<String, dynamic> json) {
    final localitiesRaw = (json['localities'] as List<dynamic>? ?? const []);
    final localities = localitiesRaw
        .whereType<Map<String, dynamic>>()
        .map(FilterLocality.fromJson)
        .toList();

    return FilterScreenResponse(
      transactionTypes: _toStringList(json['transaction_types']),
      propertyCategories: _toStringList(json['property_categories']),
      propertySubtypes: _toStringList(json['property_subtypes']),
      furnishingOptions: _toStringList(json['furnishing_options']),
      facingOptions: _toStringList(json['facing_options']),
      cities: _toStringList(json['cities']),
      localities: localities,
      priceRange: FilterRange.fromJson(
        (json['price_range'] as Map<String, dynamic>? ?? const <String, dynamic>{}),
      ),
      areaRange: FilterRange.fromJson(
        (json['area_range'] as Map<String, dynamic>? ?? const <String, dynamic>{}),
      ),
      bedrooms: _toIntList(json['bedrooms']),
      bathrooms: _toIntList(json['bathrooms']),
      storeRoomOptions: _toBoolList(json['store_room_options']),
      servantRoomOptions: _toBoolList(json['servant_room_options']),
      possessionStatusOptions: (json['possession_status_options'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((m) => {
                    'value': m['value']?.toString() ?? '',
                    'label': m['label']?.toString() ?? '',
                  })
              .toList() ??
          const [],
      availabilityMonths: (json['availability_months'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((m) => {
                    'value': m['value'],
                    'label': m['label']?.toString() ?? '',
                  })
              .toList() ??
          const [],
      availabilityYears: _toIntList(json['availability_years']),
      ageOfConstructionOptions: (json['age_of_construction_options'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((m) => {
                    'value': m['value']?.toString() ?? '',
                    'label': m['label']?.toString() ?? '',
                  })
              .toList() ??
          const [],
    );
  }
}

class FilterSelection {
  /// "BUY" / "RENT" (UI label)
  final String category;

  final String? city;
  final String? locality;
  final String? propertyCategory;
  final String? propertySubtype;
  final String? furnishing;
  final String? facing;

  // Extra filters from filter sheet
  // e.g. "Under Construction" / "Ready to move"
  final String? possessionStatus;
  // e.g. "January", "February"
  final String? availabilityMonth;
  // e.g. "2026"
  final String? availabilityYear;
  // Age-of-construction selected labels, e.g. ["New Construction", "5 to 10 Years"]
  final List<String>? ageOfConstruction;

  final num? budgetMin;
  final num? budgetMax;
  final num? areaMin;
  final num? areaMax;

  final int? bedrooms;
  final int? bathrooms;
  final List<int>? bedroomsList;

  final bool? storeRoom;
  final bool? servantRoom;

  const FilterSelection({
    required this.category,
    this.city,
    this.locality,
    this.propertyCategory,
    this.propertySubtype,
    this.furnishing,
    this.facing,
    this.possessionStatus,
    this.availabilityMonth,
    this.availabilityYear,
    this.ageOfConstruction,
    this.budgetMin,
    this.budgetMax,
    this.areaMin,
    this.areaMax,
    this.bedrooms,
    this.bathrooms,
    this.bedroomsList,
    this.storeRoom,
    this.servantRoom,
  });

  FilterSelection copyWith({
    String? category,
    String? city,
    String? locality,
    String? propertyCategory,
    String? propertySubtype,
    String? furnishing,
    String? facing,
    String? possessionStatus,
    String? availabilityMonth,
    String? availabilityYear,
    List<String>? ageOfConstruction,
    num? budgetMin,
    num? budgetMax,
    num? areaMin,
    num? areaMax,
    int? bedrooms,
    int? bathrooms,
    List<int>? bedroomsList,
    bool? storeRoom,
    bool? servantRoom,
    bool clearCity = false,
    bool clearLocality = false,
    bool clearPropertyCategory = false,
    bool clearPropertySubtype = false,
    bool clearFurnishing = false,
    bool clearFacing = false,
    bool clearPossessionStatus = false,
    bool clearAvailabilityMonth = false,
    bool clearAvailabilityYear = false,
    bool clearAgeOfConstruction = false,
    bool clearBedrooms = false,
    bool clearBedroomsList = false,
    bool clearBathrooms = false,
    bool clearStoreRoom = false,
    bool clearServantRoom = false,
    bool clearBudget = false,
    bool clearArea = false,
  }) {
    return FilterSelection(
      category: category ?? this.category,
      city: clearCity ? null : (city ?? this.city),
      locality: clearLocality ? null : (locality ?? this.locality),
      propertyCategory: clearPropertyCategory ? null : (propertyCategory ?? this.propertyCategory),
      propertySubtype: clearPropertySubtype ? null : (propertySubtype ?? this.propertySubtype),
      furnishing: clearFurnishing ? null : (furnishing ?? this.furnishing),
      facing: clearFacing ? null : (facing ?? this.facing),
      possessionStatus: clearPossessionStatus ? null : (possessionStatus ?? this.possessionStatus),
      availabilityMonth: clearAvailabilityMonth ? null : (availabilityMonth ?? this.availabilityMonth),
      availabilityYear: clearAvailabilityYear ? null : (availabilityYear ?? this.availabilityYear),
      ageOfConstruction: clearAgeOfConstruction ? null : (ageOfConstruction ?? this.ageOfConstruction),
      budgetMin: clearBudget ? null : (budgetMin ?? this.budgetMin),
      budgetMax: clearBudget ? null : (budgetMax ?? this.budgetMax),
      areaMin: clearArea ? null : (areaMin ?? this.areaMin),
      areaMax: clearArea ? null : (areaMax ?? this.areaMax),
      bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
      bedroomsList: clearBedroomsList ? null : (bedroomsList ?? this.bedroomsList),
      bathrooms: clearBathrooms ? null : (bathrooms ?? this.bathrooms),
      storeRoom: clearStoreRoom ? null : (storeRoom ?? this.storeRoom),
      servantRoom: clearServantRoom ? null : (servantRoom ?? this.servantRoom),
    );
  }

  static const empty = FilterSelection(category: 'BUY');

  bool get hasAnyFilter {
    return city != null ||
        locality != null ||
        propertyCategory != null ||
        propertySubtype != null ||
        furnishing != null ||
        facing != null ||
        possessionStatus != null ||
        availabilityMonth != null ||
        availabilityYear != null ||
        (ageOfConstruction != null && ageOfConstruction!.isNotEmpty) ||
        budgetMin != null ||
        budgetMax != null ||
        areaMin != null ||
        areaMax != null ||
        bedrooms != null ||
        (bedroomsList != null && bedroomsList!.isNotEmpty) ||
        bathrooms != null ||
        storeRoom != null ||
        servantRoom != null;
  }
}

