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
  bool sharedOfficeSpace;
  bool personalWashroom;
  bool pantry;
  String howOldIsPG;
  bool attachedBalcony;
  String securityAmount;
  bool commonArea;
  String tenantsYouPrefer;
  String laundry;

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
    this.sharedOfficeSpace = false,
    this.personalWashroom = false,
    this.pantry = false,
    this.howOldIsPG = '',
    this.attachedBalcony = false,
    this.securityAmount = '',
    this.commonArea = false,
    this.tenantsYouPrefer = '',
    this.laundry = '',
    List<String>? amenities,
    List<String>? imageUrls,
  })  : amenities = amenities ?? [],
        imageUrls = imageUrls ?? [];

  Map<String, dynamic> toApiPayload({String? ownerId}) {
    // Backend marks owner_id as required, so we must always send something.
    // Prefer the real user id; otherwise use a temporary placeholder that
    // backend can later ignore or replace.
    final String effectiveOwnerId =
        (ownerId != null && ownerId.isNotEmpty)
            ? ownerId
            : '000000000000000000000000'; // TODO: replace with real user id when login returns it

    final Map<String, dynamic> data = {
      "title": title,
      "description": description,
      "transaction_type": transactionType,
      "price": 0, // price fields are in step 2, add later if backend requires it
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
      "images": imageUrls,
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
    final location = json['location'] as Map<String, dynamic>? ?? {};

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
      
      // Location (from nested location object)
      address: location['address']?.toString() ?? '',
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
          .map((e) => e.toString())
          .toList(),
      
      // Meta
      ownerId: json['owner_id']?.toString() ?? '',
      postedAt: json['posted_at'] != null
          ? DateTime.tryParse(json['posted_at'].toString())
          : null,
    );
  }
}


