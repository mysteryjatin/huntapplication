class SubscriptionPlan {
  final String id;
  final String name;
  final int durationDays;
  final String durationLabel;
  final num priceAmount;
  final String priceDisplay;
  final String currency;
  final List<String> features;
  final String buttonLabel;
  final String imageSlug;
  final List<String> colors;
  final String textColor;
  final bool isDark;
  final bool isCurrent;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.durationLabel,
    required this.priceAmount,
    required this.priceDisplay,
    required this.currency,
    required this.features,
    required this.buttonLabel,
    required this.imageSlug,
    required this.colors,
    required this.textColor,
    required this.isDark,
    required this.isCurrent,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
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

    List<String> _toStringList(dynamic v) {
      final list = (v as List<dynamic>? ?? const []);
      return list.map((e) => e.toString()).toList();
    }

    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      durationDays: _toInt(json['duration_days']),
      durationLabel: json['duration_label']?.toString() ?? '',
      priceAmount: _toNum(json['price_amount']),
      priceDisplay: json['price_display']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'INR',
      features: _toStringList(json['features']),
      buttonLabel: json['button_label']?.toString() ?? '',
      imageSlug: json['image_slug']?.toString() ?? '',
      colors: _toStringList(json['colors']),
      textColor: json['text_color']?.toString() ?? '#000000',
      isDark: _toBool(json['is_dark']),
      isCurrent: _toBool(json['is_current']),
    );
  }
}

class SubscriptionHeader {
  final String title;
  final String subtitle;

  const SubscriptionHeader({
    required this.title,
    required this.subtitle,
  });

  factory SubscriptionHeader.fromJson(Map<String, dynamic> json) {
    return SubscriptionHeader(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
    );
  }
}

class SubscriptionFooter {
  final String secureNote;
  final String helpText;

  const SubscriptionFooter({
    required this.secureNote,
    required this.helpText,
  });

  factory SubscriptionFooter.fromJson(Map<String, dynamic> json) {
    return SubscriptionFooter(
      secureNote: json['secure_note']?.toString() ?? '',
      helpText: json['help_text']?.toString() ?? '',
    );
  }
}

class SubscriptionPlansResponse {
  final List<SubscriptionPlan> plans;
  final String? currentPlanId;
  final SubscriptionHeader header;
  final SubscriptionFooter footer;

  const SubscriptionPlansResponse({
    required this.plans,
    required this.currentPlanId,
    required this.header,
    required this.footer,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final plansRaw = data['plans'] as List<dynamic>? ?? const [];
    final plans = plansRaw
        .whereType<Map<String, dynamic>>()
        .map(SubscriptionPlan.fromJson)
        .toList();

    return SubscriptionPlansResponse(
      plans: plans,
      currentPlanId: data['current_plan_id']?.toString(),
      header: SubscriptionHeader.fromJson(
        data['header'] as Map<String, dynamic>? ?? const {},
      ),
      footer: SubscriptionFooter.fromJson(
        data['footer'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
