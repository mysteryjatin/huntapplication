class PropertyDraft {
  String title;
  String description;
  String transactionType; // Sell / Rent / etc.
  String propertyCategory; // Residential / Commercial / Agriculture
  String propertySubtype; // Flats / Villa / etc.

  int bedrooms;
  int bathrooms;
  int balconies;
  int areaSqft;
  String furnishing;
  int floorNumber;
  int totalFloors;
  int floorsAllowed;
  int openSides;
  String facing;
  bool storeRoom;
  bool servantRoom;

  String address;
  String locality;
  String city;
  String buildingName;
  String unitNumber;
  bool boundaryWallMade;
  String occupancy;
  bool attachedBathroom;
  String electricity;
  bool anyConstructionDone;
  String monthlyRent;
  /// Sale price (expected price) for transaction_type sale. Sent as "price" in API.
  String expectedPrice;
  bool sharedOfficeSpace;
  bool personalWashroom;
  bool pantry;
  String howOldIsPG;
  bool attachedBalcony;
  String securityAmount;
  bool commonArea;
  String tenantsYouPrefer;
  String laundry;

  // Extra meta fields from Step 2 (previously not sent to backend)
  String possessionStatus;   // maps to possession_status
  String availableFrom;      // maps to availability_month / text label
  String ageOfConstruction;  // maps to age_of_construction
  bool carParking;           // maps to car_parking
  bool lift;                 // maps to lift
  String typeOfOwnership;    // maps to type_of_ownership

  List<String> amenities;
  List<String> imageUrls;

  PropertyDraft({
    this.title = '',
    this.description = '',
    this.transactionType = 'Sell',
    this.propertyCategory = 'Residential',
    this.propertySubtype = '',
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.balconies = 0,
    this.areaSqft = 0,
    this.furnishing = '',
    this.floorNumber = 0,
    this.totalFloors = 0,
    this.floorsAllowed = 0,
    this.openSides = 0,
    this.facing = '',
    this.storeRoom = false,
    this.servantRoom = false,
    this.address = '',
    this.locality = '',
    this.city = '',
    this.buildingName = '',
    this.unitNumber = '',
    this.boundaryWallMade = false,
    this.occupancy = '',
    this.attachedBathroom = false,
    this.electricity = '',
    this.anyConstructionDone = false,
    this.monthlyRent = '',
    this.expectedPrice = '',
    this.sharedOfficeSpace = false,
    this.personalWashroom = false,
    this.pantry = false,
    this.howOldIsPG = '',
    this.attachedBalcony = false,
    this.securityAmount = '',
    this.commonArea = false,
    this.tenantsYouPrefer = '',
    this.laundry = '',
    this.possessionStatus = '',
    this.availableFrom = '',
    this.ageOfConstruction = '',
    this.carParking = false,
    this.lift = false,
    this.typeOfOwnership = '',
    List<String>? amenities,
    List<String>? imageUrls,
  })  : amenities = amenities ?? [],
        imageUrls = imageUrls ?? [];

  Map<String, dynamic> toApiPayload({String? ownerId}) {
    // Backend marks owner_id as required, so we must always send something.
    final String effectiveOwnerId =
        (ownerId != null && ownerId.isNotEmpty)
            ? ownerId
            : '000000000000000000000000';

    // Normalize transaction type to backend expected values: "rent" or "sale"
    String txLower = transactionType.toLowerCase();
    String apiTransactionType = 'sale';
    if (txLower.contains('rent')) {
      apiTransactionType = 'rent';
    } else if (txLower.contains('sell') || txLower.contains('sale')) {
      apiTransactionType = 'sale';
    } else {
      apiTransactionType = txLower;
    }

    // Parse price: for rent use monthlyRent, for sale use expectedPrice.
    num parsedPrice = 0;
    if (apiTransactionType == 'rent' && monthlyRent.isNotEmpty) {
      final cleaned = monthlyRent.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedPrice = num.tryParse(cleaned) ?? 0;
    } else if (apiTransactionType == 'sale' && expectedPrice.isNotEmpty) {
      final cleaned = expectedPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedPrice = num.tryParse(cleaned) ?? 0;
    }

    // Convert imageUrls (list of strings) into backend expected objects:
    // [{ "url": "...", "is_primary": true }, ...]
    final List<Map<String, dynamic>> imagesPayload = [];
    for (var i = 0; i < imageUrls.length; i++) {
      final url = imageUrls[i];
      if (url == null) continue;
      final trimmed = url.toString().trim();
      if (trimmed.isEmpty) continue;
      // Only include http/https URLs; skip local file paths (picked images)
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        imagesPayload.add({
          'url': trimmed,
          'is_primary': imagesPayload.isEmpty, // first valid becomes primary
        });
      }
    }

    int? _availabilityMonthInt() {
      final label = availableFrom.trim();
      if (label.isEmpty) return null;
      // Backend ke error se pata chala: value >= 1 honi chahiye,
      // isliye "Immediately" bhi 1 bhej rahe hain.
      if (label.toLowerCase().contains('immediately')) return 1;
      if (label.contains('1')) return 1;
      if (label.contains('3')) return 3;
      if (label.contains('7')) return 7;
      if (label.contains('9')) return 9;
      return null;
    }

    final Map<String, dynamic> data = {
      "title": title,
      "description": description,
      "transaction_type": apiTransactionType,
      "price": parsedPrice,
      "property_category": propertyCategory,
      "property_subtype": propertySubtype,
      "bedrooms": bedrooms,
      "bathrooms": bathrooms,
      "balconies": balconies,
      "area_sqft": areaSqft,
      "furnishing": furnishing,
      "floor_number": floorNumber,
      "total_floors": totalFloors,
      "floors_allowed": floorsAllowed,
      "open_sides": openSides,
      "facing": facing,
      "store_room": storeRoom,
      "servant_room": servantRoom,
      "location": {
        "address": address,
        "locality": locality,
        "city": city,
        "geo": {},
      },
      "building_name": buildingName,
      "unit_number": unitNumber,
      "boundary_wall_made": boundaryWallMade,
      "occupancy": occupancy,
      "attached_bathroom": attachedBathroom,
      "electricity": electricity,
      "any_construction_done": anyConstructionDone,
      "monthly_rent": monthlyRent,
      "shared_office_space": sharedOfficeSpace,
      "personal_washroom": personalWashroom,
      "pantry": pantry,
      "how_old_is_pg": howOldIsPG,
      "attached_balcony": attachedBalcony,
      "security_amount": securityAmount,
      "common_area": commonArea,
      "tenants_you_prefer": tenantsYouPrefer,
      "laundry": laundry,
      // Newly added fields so backend me null na jaye:
      "possession_status": possessionStatus,
      // Backend expects integer for availability_month; map UI label to months offset.
      "availability_month": _availabilityMonthInt(),
      "age_of_construction": ageOfConstruction,
      "car_parking": carParking,
      "lift": lift,
      "type_of_ownership": typeOfOwnership,
      "images": imagesPayload,
      "amenities": amenities,
      "owner_id": effectiveOwnerId,
    };

    return data;
  }
}

class Property {
  final String id;
  final String title;
  final String description;
  final String transactionType;
  final num price;
  final String propertyCategory;
  final String propertySubtype;
  final int bedrooms;
  final int bathrooms;
  final int balconies;
  final num areaSqft;
  final String furnishing;
  final int floorNumber;
  final int totalFloors;
  final int floorsAllowed;
  final int openSides;
  final String facing;
  final bool storeRoom;
  final bool servantRoom;
  final String address;
  final String locality;
  final String city;
  final String buildingName;
  final String unitNumber;
  final bool boundaryWallMade;
  final String occupancy;
  final bool attachedBathroom;
  final String electricity;
  final bool anyConstructionDone;
  final String monthlyRent;
  final bool sharedOfficeSpace;
  final bool personalWashroom;
  final bool pantry;
  final String howOldIsPG;
  final bool attachedBalcony;
  final String securityAmount;
  final bool commonArea;
  final String tenantsYouPrefer;
  final String laundry;
  final List<String> amenities;
  final List<String> images;
  final String ownerId;
  final bool isFavorite;
  final DateTime? postedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.transactionType,
    required this.price,
    required this.propertyCategory,
    required this.propertySubtype,
    required this.bedrooms,
    required this.bathrooms,
    required this.balconies,
    required this.areaSqft,
    required this.furnishing,
    required this.floorNumber,
    required this.totalFloors,
    required this.floorsAllowed,
    required this.openSides,
    required this.facing,
    required this.storeRoom,
    required this.servantRoom,
    required this.address,
    required this.locality,
    required this.city,
    required this.buildingName,
    required this.unitNumber,
    required this.boundaryWallMade,
    required this.occupancy,
    required this.attachedBathroom,
    required this.electricity,
    required this.anyConstructionDone,
    required this.monthlyRent,
    required this.sharedOfficeSpace,
    required this.personalWashroom,
    required this.pantry,
    required this.howOldIsPG,
    required this.attachedBalcony,
    required this.securityAmount,
    required this.commonArea,
    required this.tenantsYouPrefer,
    required this.laundry,
    required this.amenities,
    required this.images,
    required this.ownerId,
    this.isFavorite = false,
    required this.postedAt,
  });

  /// Parses Property from API JSON response
  /// 
  /// API Schema fields (from /api/properties/):
  /// - Core: title, description, transaction_type, price, property_category, property_subtype
  /// - Details: bedrooms, bathrooms, balconies, area_sqft, furnishing
  /// - Floor: floor_number, total_floors, floors_allowed, open_sides, facing
  /// - Features: store_room, servant_room
  /// - Location: location { address, locality, city, geo }
  /// - Media: images[], amenities[]
  /// - Meta: _id, owner_id, posted_at
  /// 
  /// Additional fields (may not be in API response, default to empty/false):
  /// - building_name, unit_number, boundary_wall_made, occupancy
  /// - attached_bathroom, electricity, any_construction_done
  /// - monthly_rent, shared_office_space, personal_washroom, pantry
  /// - how_old_is_pg, attached_balcony, security_amount, common_area
  /// - tenants_you_prefer, laundry
  factory Property.fromJson(Map<String, dynamic> json) {
    final dynamic locationRaw = json['location'];
    final Map<String, dynamic> location =
        (locationRaw is Map<String, dynamic>) ? locationRaw : {};
    // If API returns a string location (e.g. "3 BHK | Anna Nagar, Chennai"), place it into address
    String _stringLocationFallback = '';
    if (locationRaw is String) {
      _stringLocationFallback = locationRaw;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    num _toNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

    return Property(
      // Core API fields
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? '',
      price: _toNum(json['price']),
      propertyCategory: json['property_category']?.toString() ?? '',
      propertySubtype: json['property_subtype']?.toString() ?? '',
      
      // Property details
      bedrooms: _toInt(json['bedrooms']),
      bathrooms: _toInt(json['bathrooms']),
      balconies: _toInt(json['balconies']),
      areaSqft: _toNum(json['area_sqft']),
      furnishing: json['furnishing']?.toString() ?? '',
      
      // Floor information
      floorNumber: _toInt(json['floor_number']),
      totalFloors: _toInt(json['total_floors']),
      floorsAllowed: _toInt(json['floors_allowed']),
      openSides: _toInt(json['open_sides']),
      facing: json['facing']?.toString() ?? '',
      
      // Features
      storeRoom: (json['store_room'] ?? false) as bool,
      servantRoom: (json['servant_room'] ?? false) as bool,
      
      // Location (from nested location object). If backend returned a string location,
      // use it as the address fallback.
      address: location['address']?.toString() ?? _stringLocationFallback,
      locality: location['locality']?.toString() ?? '',
      city: location['city']?.toString() ?? '',
      
      // Additional fields (may not be in API response)
      buildingName: json['building_name']?.toString() ?? '',
      unitNumber: json['unit_number']?.toString() ?? '',
      boundaryWallMade: (json['boundary_wall_made'] ?? false) as bool,
      occupancy: json['occupancy']?.toString() ?? '',
      attachedBathroom: (json['attached_bathroom'] ?? false) as bool,
      electricity: json['electricity']?.toString() ?? '',
      anyConstructionDone: (json['any_construction_done'] ?? false) as bool,
      monthlyRent: json['monthly_rent']?.toString() ?? '',
      sharedOfficeSpace: (json['shared_office_space'] ?? false) as bool,
      personalWashroom: (json['personal_washroom'] ?? false) as bool,
      pantry: (json['pantry'] ?? false) as bool,
      howOldIsPG: json['how_old_is_pg']?.toString() ?? '',
      attachedBalcony: (json['attached_balcony'] ?? false) as bool,
      securityAmount: json['security_amount']?.toString() ?? '',
      commonArea: (json['common_area'] ?? false) as bool,
      tenantsYouPrefer: json['tenants_you_prefer']?.toString() ?? '',
      laundry: json['laundry']?.toString() ?? '',
      
      // Arrays
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      images: (json['images'] as List<dynamic>? ?? [])
          .map<String>((e) {
            if (e == null) return '';
            if (e is Map && e['url'] != null) {
              return e['url'].toString();
            }
            if (e is String) return e;
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList(),
      
      // Meta
      ownerId: json['owner_id']?.toString() ?? '',
      isFavorite: json['is_favorite'] is bool ? json['is_favorite'] as bool : (json['is_favorite'] != null ? (json['is_favorite'].toString().toLowerCase() == 'true') : false),
      postedAt: json['posted_at'] != null
          ? DateTime.tryParse(json['posted_at'].toString())
          : null,
    );
  }
}


