import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

/// True if the user should see platinum-tier styling (posted listing, spin reward, or non-free API label).
bool isPlatinumMembership(
  Map<String, dynamic>? profile,
  bool spinPremiumUnlocked, {
  bool hasPostedProperty = false,
}) {
  if (hasPostedProperty) return true;
  if (spinPremiumUnlocked) return true;
  final raw = profile?['subscription_type']?.toString() ??
          profile?['member_type']?.toString() ??
          '';
  final t = raw.toLowerCase().trim();
  if (t.isEmpty || t == 'free member' || t == 'free') return false;
  return true;
}

class MembershipBadge extends StatelessWidget {
  final Map<String, dynamic>? profileData;
  final bool spinPremiumUnlocked;
  /// At least one property listing exists for this user (treated as platinum tier).
  final bool hasPostedProperty;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const MembershipBadge({
    super.key,
    required this.profileData,
    required this.spinPremiumUnlocked,
    this.hasPostedProperty = false,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final showPlatinum = isPlatinumMembership(
      profileData,
      spinPremiumUnlocked,
      hasPostedProperty: hasPostedProperty,
    );
    final fallback = profileData?['subscription_type']?.toString() ??
        profileData?['member_type']?.toString() ??
        'Free member';
    final label = showPlatinum ? 'Platinum member' : fallback;

    if (showPlatinum) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.platinumBadgeGradientStart,
              AppColors.platinumBadgeGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.platinumBadgeText,
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
