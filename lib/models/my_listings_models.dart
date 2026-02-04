class MyListingItem {
  final String id;
  final String title;
  final String address;
  final String locality;
  final String city;
  final num price;
  final int viewCount;
  final int saves;
  final String listingStatus;
  final DateTime? postedAt;

  const MyListingItem({
    required this.id,
    required this.title,
    required this.address,
    required this.locality,
    required this.city,
    required this.price,
    required this.viewCount,
    required this.saves,
    required this.listingStatus,
    required this.postedAt,
  });

  factory MyListingItem.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? const {};

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

    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return MyListingItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      address: location['address']?.toString() ?? '',
      locality: location['locality']?.toString() ?? '',
      city: location['city']?.toString() ?? '',
      price: _toNum(json['price']),
      viewCount: _toInt(json['view_count']),
      saves: _toInt(json['saves']),
      listingStatus: json['listing_status']?.toString() ?? '',
      postedAt: _toDate(json['posted_at']),
    );
  }
}

class MyListingsResponse {
  final List<MyListingItem> properties;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const MyListingsResponse({
    required this.properties,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory MyListingsResponse.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['properties'] as List<dynamic>? ?? const [];
    final items = itemsRaw
        .whereType<Map<String, dynamic>>()
        .map(MyListingItem.fromJson)
        .toList();

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool _toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final lower = v.toLowerCase();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
      }
      return false;
    }

    return MyListingsResponse(
      properties: items,
      total: _toInt(json['total']),
      page: _toInt(json['page']),
      limit: _toInt(json['limit']),
      totalPages: _toInt(json['total_pages']),
      hasNext: _toBool(json['has_next']),
      hasPrev: _toBool(json['has_prev']),
    );
  }
}

