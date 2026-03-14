import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/cubit/subscription_plans_cubit.dart';
import 'package:hunt_property/models/subscription_plans_models.dart';
import 'package:hunt_property/services/subscription_plans_service.dart';

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

  @override
  void initState() {
    super.initState();
    _cubit = SubscriptionPlansCubit(SubscriptionPlansService());
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
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
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: R.h(context, 40)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _appBar(context),

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
                              ...data.plans.map((plan) {
                                // Check if this is the current plan
                                final isCurrentPlan = plan.isCurrent ||
                                    (data.currentPlanId != null &&
                                        plan.id == data.currentPlanId);

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
                                      _buildPlanCard(context, plan),
                                    ],
                                  );
                                }

                                return _buildPlanCard(context, plan);
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan) {
    // Map image_slug to asset path
    final imagePath = _getImagePath(plan.imageSlug);
    
    // Convert hex colors to Color objects
    final colors = plan.colors.map((hex) => _hexToColor(hex)).toList();
    final textColor = _hexToColor(plan.textColor);

    return _planCard(
      context,
      bg: imagePath,
      title: plan.name,
      days: plan.durationLabel,
      price: plan.priceDisplay,
      features: plan.features,
      button: plan.buttonLabel,
      colors: colors.isNotEmpty ? colors : [Colors.grey, Colors.grey],
      textColor: textColor,
      isDark: plan.isDark,
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
                _gradientButton(context, button, colors, textColor),
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
      BuildContext context, String text, List<Color> c, Color tc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: R.h(context, 13)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: c),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(text,
            style: TextStyle(
                fontSize: R.sp(context, 15),
                fontWeight: FontWeight.w700,
                color: tc)),
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
Widget _appBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const CircleAvatar(
            backgroundColor: Color(0xFFF2F4F7),
            child: Icon(Icons.arrow_back_ios_new, size: 16),
          ),
        ),
        const Spacer(),
        Text("Subscription Plans",
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w700,color: Colors.black)),
        const Spacer(),
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
