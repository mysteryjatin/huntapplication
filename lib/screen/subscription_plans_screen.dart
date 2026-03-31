import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/config/iap_product_ids.dart';
import 'package:hunt_property/cubit/subscription_plans_cubit.dart';
import 'package:hunt_property/models/subscription_plans_models.dart';
import 'package:hunt_property/services/apple_subscription_verify_service.dart';
import 'package:hunt_property/services/iap_subscription_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/services/subscription_plans_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// ================= RESPONSIVE HELPER =================
class R {
  static double w(BuildContext c, double v) =>
      MediaQuery.of(c).size.width * (v / 375);

  static double h(BuildContext c, double v) =>
      MediaQuery.of(c).size.height * (v / 812);

  static double sp(BuildContext c, double v) =>
      v * MediaQuery.of(c).textScaleFactor.clamp(1.0, 1.15);
}

/// ================= SCREEN =================
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  late final SubscriptionPlansCubit _cubit;
  final IapSubscriptionService _iap = IapSubscriptionService.instance;
  final AppleSubscriptionVerifyService _verify = AppleSubscriptionVerifyService();

  String? _iapBusyPlanId;
  String? _lastIapLoadKey;

  /// Spin reward unlocks Platinum in UI; until then Metal is the active tier.
  bool _spinPlatinumUnlocked = false;

  static const List<String> _tierOrder = [
    'metal',
    'bronze',
    'silver',
    'gold',
    'platinum',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = SubscriptionPlansCubit(SubscriptionPlansService());
    _cubit.load();
    unawaited(_loadSpinState());
    if (_iap.isIosStore) {
      _iap.onPurchaseUpdate = _onIapPurchaseUpdate;
      unawaited(_iap.ensureInitialized());
    }
  }

  @override
  void dispose() {
    if (_iap.isIosStore) {
      _iap.onPurchaseUpdate = null;
    }
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadSpinState() async {
    final v = await StorageService.hasSpinPremiumUnlocked();
    if (!mounted) return;
    if (v != _spinPlatinumUnlocked) {
      setState(() => _spinPlatinumUnlocked = v);
    }
  }

  /// Prefer plan id; fall back to image_slug when API uses opaque ids.
  String _tierKey(SubscriptionPlan plan) {
    final id = plan.id.toLowerCase().trim();
    if (id.isNotEmpty && _tierOrder.contains(id)) return id;
    final slug = plan.imageSlug.toLowerCase().trim();
    if (slug.isNotEmpty && _tierOrder.contains(slug)) return slug;
    return id.isNotEmpty ? id : slug;
  }

  int _tierRank(SubscriptionPlan plan) {
    final i = _tierOrder.indexOf(_tierKey(plan));
    return i >= 0 ? i : 999;
  }

  List<SubscriptionPlan> _sortPlansByTier(List<SubscriptionPlan> plans) {
    final copy = List<SubscriptionPlan>.from(plans);
    copy.sort((a, b) => _tierRank(a).compareTo(_tierRank(b)));
    return copy;
  }

  /// Effective "current" plan for this screen (Metal before spin, Platinum after).
  bool _effectiveIsCurrent(SubscriptionPlan plan) {
    final key = _tierKey(plan);
    if (!_spinPlatinumUnlocked) return key == 'metal';
    return key == 'platinum';
  }

  String _effectiveCtaLabel(SubscriptionPlan plan) {
    final key = _tierKey(plan);
    if (!_spinPlatinumUnlocked) {
      if (key == 'metal') return 'Active Plan';
      return 'Upgrade to ${plan.name.trim()}';
    }
    if (key == 'platinum') return 'Active Plan';
    return 'Downgrade';
  }

  Future<void> _onIapPurchaseUpdate(PurchaseDetails details) async {
    if (details.status == PurchaseStatus.pending) {
      if (mounted) setState(() {});
      return;
    }

    if (details.status == PurchaseStatus.error) {
      if (mounted) {
        setState(() => _iapBusyPlanId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(details.error?.message ?? 'Purchase failed'),
          ),
        );
      }
      return;
    }

    if (details.status == PurchaseStatus.canceled) {
      if (mounted) setState(() => _iapBusyPlanId = null);
      return;
    }

    if (details.status == PurchaseStatus.purchased ||
        details.status == PurchaseStatus.restored) {
      var receipt = details.verificationData.localVerificationData;
      if (receipt.isEmpty) {
        receipt = details.verificationData.serverVerificationData;
      }
      if (receipt.isEmpty) {
        if (mounted) setState(() => _iapBusyPlanId = null);
        return;
      }

      final result = await _verify.verifyPurchase(receiptData: receipt);
      if (result.success) {
        await _iap.completePurchase(details);
        if (mounted) {
          await _cubit.load();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? 'Subscription updated')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? 'Verification failed')),
          );
        }
      }
      if (mounted) setState(() => _iapBusyPlanId = null);
    }
  }

  void _maybeLoadIapProducts(SubscriptionPlansResponse data) {
    if (!_iap.isIosStore) return;
    final key = '${data.currentPlanId}_${data.plans.map((e) => e.id).join()}';
    if (_lastIapLoadKey == key) return;
    _lastIapLoadKey = key;

    final ids = <String>{};
    for (final p in data.plans) {
      final id = p.appleProductId ?? IapProductIds.forPlanId(p.id);
      if (id != null && id.isNotEmpty) ids.add(id);
    }
    unawaited(_iap.queryProducts(ids));
  }

  Future<void> _onPlanButtonTap(SubscriptionPlan plan) async {
    if (_effectiveIsCurrent(plan)) return;

    if (Platform.isAndroid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Play billing for subscriptions is not yet enabled in this build. '
            'Use the iOS app with In-App Purchase, or contact support.',
          ),
        ),
      );
      return;
    }

    if (!_iap.isIosStore) return;

    if (plan.id == 'metal' || plan.priceAmount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This is the free tier. To switch to Metal, contact support if you need account changes.',
          ),
        ),
      );
      return;
    }

    final appleId = plan.appleProductId ?? IapProductIds.forPlanId(plan.id);
    if (appleId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No App Store product for this plan.')),
      );
      return;
    }

    final product = _iap.productForPlan(appleId);
    if (product == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Products are not available yet. Add them in App Store Connect and match the product IDs.',
          ),
        ),
      );
      return;
    }

    setState(() => _iapBusyPlanId = plan.id);
    final started = await _iap.buy(product);
    if (!started && mounted) {
      setState(() => _iapBusyPlanId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start purchase.')),
      );
    }
  }

  Future<void> _restorePurchases() async {
    if (!_iap.isIosStore) return;
    setState(() => _iapBusyPlanId = '_restore');
    await _iap.restorePurchases();
    if (mounted) setState(() => _iapBusyPlanId = null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: BlocListener<SubscriptionPlansCubit, SubscriptionPlansState>(
                    listenWhen: (prev, curr) => curr is SubscriptionPlansLoaded,
                    listener: (context, state) {
                      unawaited(_loadSpinState());
                    },
                    child: BlocBuilder<SubscriptionPlansCubit, SubscriptionPlansState>(
                    builder: (context, state) {
                      if (state is SubscriptionPlansLoading ||
                          state is SubscriptionPlansInitial) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is SubscriptionPlansError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _cubit.load(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is SubscriptionPlansLoaded) {
                        final data = state.data;
                        final sortedPlans = _sortPlansByTier(data.plans);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _maybeLoadIapProducts(data);
                        });
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: R.h(context, 40)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _appBar(
                                context,
                                showRestorePurchases: _iap.isIosStore,
                                onRestorePurchases: _iapBusyPlanId != null ? null : _restorePurchases,
                              ),

                              SizedBox(height: R.h(context, 20)),

                              /// -------- HEADER CARD --------
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
                                padding: EdgeInsets.all(R.w(context, 16)),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDFF2FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF28E29A)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.header.title.isNotEmpty
                                          ? data.header.title
                                          : "Choose your growth partner",
                                      style: TextStyle(
                                        fontSize: R.sp(context, 16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: R.h(context, 4)),
                                    Text(
                                      data.header.subtitle.isNotEmpty
                                          ? data.header.subtitle
                                          : "Upgrade to higher tiers for better visibility and faster leads.",
                                      style: TextStyle(
                                        fontSize: R.sp(context, 12),
                                        color: const Color(0xFF7A7D80),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: R.h(context, 18)),

                              /// -------- PLANS --------
                              /// Metal = active before spin; Platinum = active after spin (CTA labels).
                              ...sortedPlans.map((plan) {
                                final isCurrentPlan = _effectiveIsCurrent(plan);

                                if (isCurrentPlan) {
                                  return Column(
                                    children: [
                                      const Text(
                                        "YOUR CURRENT PLAN",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      _buildPlanCard(
                                        context,
                                        plan,
                                        isCurrentPlan: true,
                                        buttonLabel: _effectiveCtaLabel(plan),
                                      ),
                                    ],
                                  );
                                }

                                return _buildPlanCard(
                                  context,
                                  plan,
                                  isCurrentPlan: false,
                                  buttonLabel: _effectiveCtaLabel(plan),
                                );
                              }),

                              SizedBox(height: R.h(context, 24)),

                              /// -------- FOOTER --------
                              Center(
                                child: Text(
                                  data.footer.secureNote.isNotEmpty
                                      ? data.footer.secureNote
                                      : "Secure payment   |   Cancel anytime.",
                                  style: TextStyle(
                                    fontSize: R.sp(context, 13),
                                    color: Colors.black54,
                                  ),
                                ),
                              ),

                              SizedBox(height: R.h(context, 6)),

                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.help_outline,
                                        size: R.sp(context, 16),
                                        color: Colors.black54),
                                    SizedBox(width: R.w(context, 6)),
                                    Text(
                                      data.footer.helpText.isNotEmpty
                                          ? data.footer.helpText
                                          : "Need help? Contact our support team.",
                                      style: TextStyle(
                                        fontSize: R.sp(context, 13),
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: R.h(context, 20)),

                              _divider(),

                              SizedBox(height: R.h(context, 12)),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
                                child: Column(
                                  children: const [
                                    ContactRow(
                                      icon: Icons.call,
                                      title: "Call Us",
                                      lines: ["Call us at: 85588 002009"],
                                    ),
                                    ContactRow(
                                      icon: Icons.mail,
                                      title: "Mail Us",
                                      highlightGreen: true,
                                      lines: [
                                        "Mail us for Sales/Service/Enquires",
                                        "info@huntproperty.com",
                                        "customercare@huntproperty.com",
                                      ],
                                    ),
                                    ContactRow(
                                      icon: Icons.info_outline,
                                      title: "For More Information",
                                      highlightGreen: true,
                                      lines: ["Continue with Customer Services"],
                                    ),
                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan, {
    required bool isCurrentPlan,
    required String buttonLabel,
  }) {
    // Map image_slug to asset path
    final imagePath = _getImagePath(plan.imageSlug);

    // Convert hex colors to Color objects
    final colors = plan.colors.map((hex) => _hexToColor(hex)).toList();
    final textColor = _hexToColor(plan.textColor);

    final bool canTap = !isCurrentPlan;
    final bool loading = _iapBusyPlanId == plan.id;

    return _planCard(
      context,
      bg: imagePath,
      title: plan.name,
      days: plan.durationLabel,
      price: plan.priceDisplay,
      features: plan.features,
      button: buttonLabel,
      colors: colors.isNotEmpty ? colors : [Colors.grey, Colors.grey],
      textColor: textColor,
      isDark: plan.isDark,
      onButtonTap: canTap ? () => _onPlanButtonTap(plan) : null,
      buttonLoading: loading,
    );
  }

  String _getImagePath(String imageSlug) {
    // Map image_slug to asset path
    switch (imageSlug.toLowerCase()) {
      case 'metal':
        return "assets/images/metal.png";
      case 'bronze':
        return "assets/images/bronze.png";
      case 'silver':
      case 'sliver': // Handle typo in existing code
        return "assets/images/sliver.png";
      case 'gold':
        return "assets/images/gold.png";
      case 'platinum':
        return "assets/images/platinum.png";
      default:
        return "assets/images/metal.png"; // fallback
    }
  }

  Color _hexToColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      if (hexCode.length == 6) {
        return Color(int.parse('FF$hexCode', radix: 16));
      } else if (hexCode.length == 8) {
        return Color(int.parse(hexCode, radix: 16));
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing color: $hex - $e');
    }
    return Colors.black; // fallback
  }

  /// ================= PLAN CARD =================
  Widget _planCard(
      BuildContext context, {
        required String bg,
        required String title,
        required String days,
        required String price,
        required List<String> features,
        required String button,
        required List<Color> colors,
        required Color textColor,
        bool isDark = false,
        VoidCallback? onButtonTap,
        bool buttonLoading = false,
      }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.asset(bg, fit: BoxFit.cover, width: double.infinity),
          Container(
            padding: EdgeInsets.all(R.w(context, 16)),
            color: Colors.white.withOpacity(0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, title, days, price, isDark),
                SizedBox(height: R.h(context, 14)),
                ...features.map(
                      (e) => Padding(
                    padding: EdgeInsets.only(bottom: R.h(context, 6)),
                    child: Row(
                      children: [
                        Icon(Icons.check,
                            size: R.sp(context, 16),
                            color: isDark ? Colors.white : Colors.black),
                        SizedBox(width: R.w(context, 8)),
                        Expanded(
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: R.sp(context, 14),
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(context, 16)),
                _gradientButton(
                  context,
                  button,
                  colors,
                  textColor,
                  onTap: onButtonTap,
                  loading: buttonLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// ================= HEADER =================
  Widget _header(
      BuildContext context, String t, String d, String p, bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t,
                style: TextStyle(
                    fontSize: R.sp(context, 17),
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : Colors.black)),
            Text(d,
                style: TextStyle(
                    fontSize: R.sp(context, 13),
                    color: dark ? Colors.white70 : Colors.black54)),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: R.w(context, 16), vertical: R.h(context, 8)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(p,
              style: TextStyle(
                  fontSize: R.sp(context, 16),
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  /// ================= BUTTON =================
  Widget _gradientButton(
    BuildContext context,
    String text,
    List<Color> c,
    Color tc, {
    VoidCallback? onTap,
    bool loading = false,
  }) {
    final child = loading
        ? SizedBox(
            height: R.h(context, 22),
            width: R.h(context, 22),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: tc,
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: R.sp(context, 15),
              fontWeight: FontWeight.w700,
              color: tc,
            ),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: R.h(context, 13)),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: c),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// ================= CONTACT ROW =================
class ContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;
  final bool highlightGreen;

  const ContactRow({
    super.key,
    required this.icon,
    required this.title,
    required this.lines,
    this.highlightGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: Color(0xFF9E9E9E),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                ...lines.map(
                      (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight:
                        highlightGreen ? FontWeight.w500 : FontWeight.w400,
                        color: highlightGreen
                            ? const Color(0xFF1ED760) // GREEN
                            : const Color(0xFF8A8A8A), // GREY
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= APP BAR =================
Widget _appBar(
  BuildContext context, {
  bool showRestorePurchases = false,
  VoidCallback? onRestorePurchases,
}) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFF2F4F7),
              child: Icon(Icons.arrow_back_ios_new, size: 16),
            ),
          ),
        ),
        Text(
          "Subscription Plans",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        if (showRestorePurchases)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRestorePurchases,
              child: Text(
                'Restore',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF28E29A),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// ================= DIVIDER =================
Widget _divider() {
  return Column(
    children: [
      Container(height: 1, color: Color(0xFFE6E2E2)),
      Container(
        height: 8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3E3E3).withOpacity(.45),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ],
  );
}
