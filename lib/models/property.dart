import 'dart:convert';

class Property {
  final String id;
  final String title;
  final String description;
  final String transactionType;
  final double? price;
  final String propertyCategory;
  final String? propertySubtype;
  final int? bedrooms;
  final int? bathrooms;
  final double? areaSqft;
  final double? carpetArea;
  final double? plotArea;
  final int? balconies;
  final String? furnishing;
  final Location? location;
  final List<PropertyImage> images;
  final List<String> amenities;
  final String listingStatus;
  final bool? lift;
  final String? furnishedStatus;
  final String? typeOfOwnership;
  final int? floorNumber;
  final int? totalFloors;
  final String? facing;
  final int? viewCount;
  final String? ownerId;
  final DateTime? postedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.transactionType,
    this.price,
    required this.propertyCategory,
    this.propertySubtype,
    this.bedrooms,
    this.bathrooms,
    this.areaSqft,
    this.carpetArea,
    this.plotArea,
    this.balconies,
    this.floorNumber,
    this.totalFloors,
    this.facing,
    this.furnishing,
    this.location,
    this.images = const [],
    this.amenities = const [],
    required this.listingStatus,
    this.lift,
    this.furnishedStatus,
    this.typeOfOwnership,
    this.viewCount,
    this.ownerId,
    this.postedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? null;
      return null;
    }

    return Property(
      id: json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      transactionType: json['transaction_type'] as String? ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : null,
      propertyCategory: json['property_category'] as String? ?? '',
      propertySubtype: json['property_subtype'] as String? ?? '',
      bedrooms: json['bedrooms'] != null ? (json['bedrooms'] as num).toInt() : null,
      bathrooms: json['bathrooms'] != null ? (json['bathrooms'] as num).toInt() : null,
      balconies: json['balconies'] != null ? (json['balconies'] as num).toInt() : null,
      floorNumber: json['floor_number'] != null ? (json['floor_number'] as num).toInt() : null,
      totalFloors: json['total_floors'] != null ? (json['total_floors'] as num).toInt() : null,
      areaSqft: (json['area_sqft'] != null) ? (json['area_sqft'] as num).toDouble() : null,
      carpetArea: _toDouble(json['carpet_area'] ?? json['carpetArea']),
      plotArea: _toDouble(json['plot_area'] ?? json['plotArea']),
      furnishing: json['furnishing'] as String?,
      location: json['location'] != null ? Location.fromJson(json['location'] as Map<String, dynamic>) : null,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      listingStatus: json['listing_status'] as String? ?? '',
      lift: (json['lift'] ?? json['has_lift']) as bool? ?? null,
      furnishedStatus: json['furnished_status'] as String? ?? json['furnishedStatus'] as String?,
      typeOfOwnership: json['type_of_ownership'] as String? ?? json['typeOfOwnership'] as String?,
      facing: json['facing'] as String? ?? json['face'] as String?,
      viewCount: json['view_count'] != null ? (json['view_count'] as num).toInt() : null,
      ownerId: json['owner_id'] as String?,
      postedAt: json['posted_at'] != null ? DateTime.tryParse(json['posted_at'] as String) : null,
      // optional floor / total floors / facing from API if present
      // parse later via cascade since constructor above expects these fields to exist;
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'transaction_type': transactionType,
      'price': price,
      'property_category': propertyCategory,
      'property_subtype': propertySubtype,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sqft': areaSqft,
      'carpet_area': carpetArea,
      'plot_area': plotArea,
      'furnishing': furnishing,
      'location': location?.toJson(),
      'images': images.map((i) => i.toJson()).toList(),
      'amenities': amenities,
      'listing_status': listingStatus,
      'lift': lift,
      'furnished_status': furnishedStatus,
      'type_of_ownership': typeOfOwnership,
      'floor_number': floorNumber,
      'total_floors': totalFloors,
      'facing': facing,
      'view_count': viewCount,
      'owner_id': ownerId,
      'posted_at': postedAt?.toIso8601String(),
    };
  }
}

class Location {
  final String? address;
  final String? locality;
  final String? city;
  final GeoPoint? geo;

  Location({this.address, this.locality, this.city, this.geo});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] as String?,
      locality: json['locality'] as String?,
      city: json['city'] as String?,
      geo: json['geo'] != null ? GeoPoint.fromJson(json['geo'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'locality': locality,
      'city': city,
      'geo': geo?.toJson(),
    };
  }
}

class GeoPoint {
  final String? type;
  final List<double>? coordinates;

  GeoPoint({this.type, this.coordinates});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class PropertyImage {
  final String url;
  final bool isPrimary;

  PropertyImage({required this.url, required this.isPrimary});

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      url: json['url'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'is_primary': isPrimary,
    };
  }
}

