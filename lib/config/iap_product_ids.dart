/// Maps subscription plan IDs to App Store Connect product identifiers.
///
/// Create matching **Auto-Renewable Subscriptions** in App Store Connect under one
/// subscription group, using these exact IDs (or override via API field `apple_product_id`).
class IapProductIds {
  IapProductIds._();

  /// Must match App Store Connect exactly (e.g. Hunt Property Listing Plans group).
  static const String bundlePrefix = 'com.hunt.property.subscription';

  /// Paid tiers only. Metal (free) has no StoreKit product.
  static String? forPlanId(String planId) {
    switch (planId.toLowerCase()) {
      case 'bronze':
        return '$bundlePrefix.bronze';
      case 'silver':
        return '$bundlePrefix.silver';
      case 'gold':
        return '$bundlePrefix.gold';
      case 'platinum':
        return '$bundlePrefix.platinum';
      default:
        return null;
    }
  }

  static Set<String> allPaidProductIds() => {
        '$bundlePrefix.bronze',
        '$bundlePrefix.silver',
        '$bundlePrefix.gold',
        '$bundlePrefix.platinum',
      };
}
