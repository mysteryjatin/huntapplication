import 'package:flutter/material.dart';

class AdvertiseWithUsScreen extends StatefulWidget {
  const AdvertiseWithUsScreen({super.key});

  @override
  State<AdvertiseWithUsScreen> createState() => _AdvertiseWithUsScreenState();
}

class _AdvertiseWithUsScreenState extends State<AdvertiseWithUsScreen> {
  int selectedIndex = -1;

  final List<Map<String, String>> packages = [
    {
      "title": "Horizontal\nBanners (Home Page)",
      "price": "₹ 35000",
    },
    {
      "title": "Vertical\nBanners (Home Page)",
      "price": "₹ 35000",
    },
    {
      "title": "Horizontal\nBanners (Dashboard)",
      "price": "₹ 35000",
    },
    {
      "title": "Vertical\nBanners (Dashboard)",
      "price": "₹ 35000",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _appBar(context),
              const SizedBox(height: 6),
              _title(),
              const SizedBox(height: 16),
              _packageGrid(),
              const SizedBox(height: 24),
              _paymentButton(),
              const SizedBox(height: 26),
              _divider(),
              const SizedBox(height: 26),
              _contactSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // APP BAR EXACT SS
  // ------------------------------------------------------------
  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffeef6ff),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Text(
              "Advertise with Us",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TITLE
  // ------------------------------------------------------------
  Widget _title() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        "Select Package",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }

  // ------------------------------------------------------------
  // PACKAGE GRID 2x2 EXACT SS STYLE
  // ------------------------------------------------------------
  Widget _packageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: packages.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, i) {
          return _packageCard(
            title: packages[i]["title"]!,
            price: packages[i]["price"]!,
            index: i,
          );
        },
      ),
    );
  }

  Widget _packageCard({
    required String title,
    required String price,
    required int index,
  }) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffeef6ff),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffeef6ff),
                borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(14)),
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                    isSelected ? const Color(0xFF2FED9A) : Colors.grey,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    price,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PAYMENT BUTTON EXACT SS GREEN
  // ------------------------------------------------------------
  Widget _paymentButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: selectedIndex == -1 ? null : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedIndex == -1
                ? Colors.grey.shade300
                : const Color(0xff18e285),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            "Payment",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DIVIDER BAR EXACT SAME
  // ------------------------------------------------------------
  Widget _divider() {
    return Container(
      width: double.infinity,
      height: 10,
      color: Colors.grey.shade200,
    );
  }

  // ------------------------------------------------------------
  // CONTACT SECTION EXACT SS
  // ------------------------------------------------------------
  Widget _contactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _contactItem(
            icon: Icons.call,
            title: "Call Us",
            subtitle: "Call us at: 85588 002009",
          ),
          const SizedBox(height: 26),

          _contactItem(
            icon: Icons.mail_outline,
            title: "Mail Us",
            subtitle: "Mail us for Sales/Service/Enquires",
            extra: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 6),
                Text(
                  "info@huntproperty.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff18E285),   // GREEN
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "customercare@huntproperty.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff18E285),   // GREEN
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),

          _contactItem(
            icon: Icons.info_outline,
            title: "For More Information",
            subtitle: "",
            extra: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "Continue with Customer Services",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff18E285),   // GREEN
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? extra,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xffEEF6FF), // LIGHT BLUE BG
          child: Icon(
            icon,
            color: Color(0xff6B6B6B), // DARK GREY ICON
            size: 22,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black, // BLACK TITLE
                ),
              ),

              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff9E9E9E), // GREY SUBTITLE
                  ),
                ),
              ],

              if (extra != null) extra,
            ],
          ),
        ),
      ],
    );
  }

}
