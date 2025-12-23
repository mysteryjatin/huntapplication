import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
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
                              "Choose your growth partner",
                              style: TextStyle(
                                fontSize: R.sp(context, 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: R.h(context, 4)),
                            Text(
                              "Upgrade to higher tiers for better visibility and faster leads.",
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
                      _planCard(
                        context,
                        bg: "assets/images/metal.png",
                        title: "Metal",
                        days: "30 Days",
                        price: "Free",
                        features: [
                          "1 Listing",
                          "Free Posting",
                          "Photos Posting (Upto 5MB)",
                        ],
                        button: "Downgrade",
                        colors: const [Color(0xFFA4A4A4), Color(0xFFA3A2A2)],
                        textColor: Colors.black,
                      ),

                      _planCard(
                        context,
                        bg: "assets/images/bronze.png",
                        title: "Bronze",
                        days: "60 Days",
                        price: "₹ 730",
                        features: [
                          "5 Listing",
                          "Chat Option",
                          "Expert Property Description",
                          "Buyer Contacts",
                        ],
                        button: "Downgrade",
                        colors: const [Color(0xFFA35C2C), Color(0xFFCF895A)],
                        textColor: Colors.white,
                      ),

                      _currentPlan(context),

                      _planCard(
                        context,
                        bg: "assets/images/gold.png",
                        title: "Gold",
                        days: "120 Days",
                        price: "₹ 3500",
                        features: [
                          "7 Listing",
                          "Video Posting",
                          "SMS & Email Alerts",
                          "Verified Tag",
                          "Premium Visibility",
                        ],
                        button: "Upgrade to Gold",
                        colors: const [Color(0xFFF6ECA5), Color(0xFFD79E08)],
                        textColor: Colors.black,
                      ),

                      _planCard(
                        context,
                        bg: "assets/images/platinum.png",
                        title: "Platinum",
                        days: "150 Days",
                        price: "₹ 5000",
                        features: [
                          "9 Listing",
                          "All Gold Features",
                          "Top Search Rank",
                          "Dedicated Relationship Manager",
                          "Social Media Promotion",
                        ],
                        button: "Upgrade to Platinum",
                        colors: const [Color(0xFF315A81), Color(0xFF1E2B4B)],
                        textColor: Colors.white,
                        isDark: true,
                      ),

                      SizedBox(height: R.h(context, 24)),

                      /// -------- FOOTER --------
                      Center(
                        child: Text(
                          "Secure payment   |   Cancel anytime.",
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
                              "Need help? Contact our support team.",
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
                ),
              ),
            );
          },
        ),
      ),
    );
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

  /// ================= CURRENT PLAN =================
  Widget _currentPlan(BuildContext context) {
    return Column(
      children: [
        const Text(
          "YOUR CURRENT PLAN",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        _planCard(
          context,
          bg: "assets/images/sliver.png",
          title: "Silver",
          days: "90 Days",
          price: "₹ 1400",
          features: [
            "5 Listing",
            "Email Alerts",
            "Chat Option",
            "Get Buyer Contacts",
            "Expert Property Description",
          ],
          button: "Active Plan",
          colors: const [Color(0xFFEDECEA), Color(0xFFBEBDBC)],
          textColor: Colors.black,
        ),
      ],
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
                fontSize: 20, fontWeight: FontWeight.w700)),
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
