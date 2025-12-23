import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';

class NRICenterScreen extends StatefulWidget {
  const NRICenterScreen({super.key});

  @override
  State<NRICenterScreen> createState() => _NRICenterScreenState();
}

class _NRICenterScreenState extends State<NRICenterScreen> {
  static const Color kGreen = Color(0xFF2FED9A);
  static const Color kBg = Color(0xFFF6FAFF);
  static const Color kBorder = Color(0xFFD9D9D9);

  bool nriExpanded = true;
  int expandedFaq = -1;

  final faqList = [
    {
      "q": "Do NRI pay property tax in India?",
      "a":
      "Yes. NRIs must pay property tax for any immovable property owned in India."
    },
    {
      "q": "Can NRI buy property in India without Aadhar card?",
      "a": "Yes, NRIs can purchase property without an Aadhar card."
    },
    {
      "q": "Can NRI transfer property in India?",
      "a":
      "Yes. NRIs can transfer ownership through a registered sale or gift deed."
    },
    {
      "q": "Do NRI pay TDS on property?",
      "a":
      "Yes, NRIs need to pay TDS on property transactions as per Indian laws."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _appBar(context),

              // =================== MAIN CARD ===================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topImage(),

                    const SizedBox(height: 14),

                    _nriSection(),

                    const SizedBox(height: 14),

                    ...List.generate(faqList.length, (i) {
                      return _faqTile(i);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =================== QUERY FORM ===================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "NRI QUERY",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "NRI Query Form",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _input("First Name *"),
                    _input("Last Name"),
                    _input("Email"),
                    _input("Phone number *"),
                    _input("State *"),
                    _input("Country *"),
                    _messageInput("Message *"),

                    const SizedBox(height: 18),
                    _submitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= APP BAR =================
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
          Text(
            "NRI Center",
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }


  // ================= CARD DECOR =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
        color: const Color(0xfff2f8ff),
      borderRadius: BorderRadius.circular(18),

      // ✅ ADD BORDER
      border: Border.all(
        color: const Color(0xFFE3E6EA), // light grey border (SS style)
        width: 1,
      ),

      // ✅ SOFT SHADOW
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }


  // ================= TOP IMAGE =================

  Widget _topImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        "assets/images/post.png", // replace with your asset
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // ================= NRI SECTION =================

  Widget _nriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("NRI SECTION",
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w700,color: Colors.black)),

        const SizedBox(height: 6),

        GestureDetector(
          onTap: () => setState(() => nriExpanded = !nriExpanded),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "NRI Investments in Indian Real Estate",
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(
                nriExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),

        if (nriExpanded) const SizedBox(height: 10),

        if (nriExpanded)
          Text(
            _nriLongText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
      ],
    );
  }

  // ================= FAQ TILE =================

  Widget _faqTile(int index) {
    final bool open = expandedFaq == index;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            expandedFaq = open ? -1 : index;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    faqList[index]["q"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),

        if (open)
          Padding(
            padding:
            const EdgeInsets.only(left: 4, right: 4, bottom: 12),
            child: Text(
              faqList[index]["a"]!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

        // ✅ DIVIDER (LIKE SCREENSHOT)
        if (index != faqList.length - 1)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE6E9ED),
          ),
      ],
    );
  }

  // ================= INPUTS =================

  Widget _input(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageInput(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ================= SUBMIT =================

  Widget _submitButton() {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          "Submit",
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700,color: Colors.black),
        ),
      ),
    );
  }
}

// ================= LONG TEXT =================

const String _nriLongText = '''
1. NRI investments in Indian Real Estate will give you glimpses of investment in the real estate sector which is one of the most popular investment avenues for non-resident Indians (NRIs).
2. There are some important tax and regulatory considerations that non-residents should take note of before making investments in this sector.
3. Foreign Exchange Regulations in Real Estate Investment (FEMA) are given below.
4. Who can invest?
NRI and OCI citizens can invest in India.
5. Types of permitted real estate.
6. Ways to invest.
7. Mode of payment and taxation rules apply as per RBI guidelines.
''';
// ---------------- APP BAR ----------------

