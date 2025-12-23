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
    List<String>? amenities,
    List<String>? imageUrls,
  })  : amenities = amenities ?? [],
        imageUrls = imageUrls ?? [];

  Map<String, dynamic> toApiPayload(String ownerId) {
    return {
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
      "images": imageUrls,
      "amenities": amenities,
      "owner_id": ownerId,
    };
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
  final int areaSqft;
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
    required this.amenities,
    required this.images,
    required this.ownerId,
    required this.postedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};

    return Property(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? '',
      price: json['price'] ?? 0,
      propertyCategory: json['property_category']?.toString() ?? '',
      propertySubtype: json['property_subtype']?.toString() ?? '',
      bedrooms: (json['bedrooms'] ?? 0) as int,
      bathrooms: (json['bathrooms'] ?? 0) as int,
      balconies: (json['balconies'] ?? 0) as int,
      areaSqft: (json['area_sqft'] ?? 0) as int,
      furnishing: json['furnishing']?.toString() ?? '',
      floorNumber: (json['floor_number'] ?? 0) as int,
      totalFloors: (json['total_floors'] ?? 0) as int,
      floorsAllowed: (json['floors_allowed'] ?? 0) as int,
      openSides: (json['open_sides'] ?? 0) as int,
      facing: json['facing']?.toString() ?? '',
      storeRoom: (json['store_room'] ?? false) as bool,
      servantRoom: (json['servant_room'] ?? false) as bool,
      address: location['address']?.toString() ?? '',
      locality: location['locality']?.toString() ?? '',
      city: location['city']?.toString() ?? '',
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      ownerId: json['owner_id']?.toString() ?? '',
      postedAt: json['posted_at'] != null
          ? DateTime.tryParse(json['posted_at'].toString())
          : null,
    );
  }
}


