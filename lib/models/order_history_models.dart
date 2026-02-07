class OrderItem {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final num amount;
  final String currency;
  final String status;
  final String orderNumber;
  final String title;
  final DateTime? createdAt;

  const OrderItem({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.orderNumber,
    required this.title,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    num _toNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

    return OrderItem(
      id: json['_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      planId: json['plan_id']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? '',
      amount: _toNum(json['amount']),
      currency: json['currency']?.toString() ?? 'INR',
      status: json['status']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: _toDate(json['created_at']),
    );
  }
}

class OrderHistoryResponse {
  final List<OrderItem> orders;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const OrderHistoryResponse({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    final ordersRaw = json['orders'] as List<dynamic>? ?? const [];
    final orders = ordersRaw
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
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

    return OrderHistoryResponse(
      orders: orders,
      total: _toInt(json['total']),
      page: _toInt(json['page']),
      limit: _toInt(json['limit']),
      totalPages: _toInt(json['total_pages']),
      hasNext: _toBool(json['has_next']),
      hasPrev: _toBool(json['has_prev']),
    );
  }
}
