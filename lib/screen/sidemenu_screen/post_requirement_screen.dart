import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';

class PostRequirementScreen extends StatefulWidget {
  const PostRequirementScreen({super.key});

  @override
  State<PostRequirementScreen> createState() => _PostRequirementScreenState();
}

class _PostRequirementScreenState extends State<PostRequirementScreen> {
  // ---------------- COLORS ----------------
  static const Color kBorder = Color(0xFFD0D0D0);
  static const Color kBg = Color(0xFFF6FAFF);

  // ---------------- STATES ----------------
  int iamIndex = 0;
  int residentIndex = 0;
  int wantIndex = 0;
  int propertyType = 0;
  int optionIndex = -1;
  int bhkIndex = 0;
  int finishingIndex = 0;
  int possessionIndex = 0;
  int paymentIndex = 0;

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
              const SizedBox(height: 14),

              // -------- MAIN CARD --------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardbg,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topImage(),
                    const SizedBox(height: 14),
                    _centerTitle(),

                    const SizedBox(height: 22),
                    _section("Personal Details"),

                    _label("I am"),
                    pillWrap(
                      ["Individual", "Corporate"],
                      iamIndex,
                          (i) => setState(() => iamIndex = i),
                    ),

                    inputField("Name"),
                    inputField("Email"),
                    inputField("Mobile"),
                    inputField("Country"),
                    inputField("State"),
                    const SizedBox(height: 14),

                    pillWrap(
                      ["Resident", "Non Resident"],
                      residentIndex,
                          (i) => setState(() => residentIndex = i),
                    ),

                    _label("I want"),
                    pillWrap(
                      ["To Buy", "To Rent", "Other Services"],
                      wantIndex,
                          (i) => setState(() => wantIndex = i),
                    ),

                    const SizedBox(height: 24),
                    _section("Property Info"),

                    _label("Property Type"),
                    pillWrap(
                      ["Residential", "Commercial", "Agricultural"],
                      propertyType,
                          (i) => setState(() => propertyType = i),
                    ),

                    _label("Options"),
                    pillWrap(
                      [
                        "House or Kothi",
                        "Builder Floor",
                        "Villa",
                        "Service Apartment",
                        "Penthouse",
                        "Studio Apartment",
                        "Flats",
                        "Duplex",
                        "Plot/Land",
                      ],
                      optionIndex,
                          (i) => setState(() => optionIndex = i),
                    ),

                    dropdownField("State"),
                    dropdownField("City"),
                    inputField("Locality"),

                    _label("Select BHK"),
                    pillWrap(
                      ["1 BHK", "2 BHK", "3 BHK", "4 BHK"],
                      bhkIndex,
                          (i) => setState(() => bhkIndex = i),
                    ),

                    _label("Type of Finishing"),
                    pillWrap(
                      ["Bare Shell", "Semi Furnished", "Fully Furnished"],
                      finishingIndex,
                          (i) => setState(() => finishingIndex = i),
                    ),

                    // ✅ UPDATED POSSESSION (ONE LINE)
                    _label("Possession"),
                    possessionRow(),

                    twoInputRow("Min Area", "Max Area"),
                    twoInputRow("Min Price", "Max Price"),

                    _label("Payment Plan"),
                    pillWrap(
                      ["CLP", "SPP", "FLEXI"],
                      paymentIndex,
                          (i) => setState(() => paymentIndex = i),
                    ),

                    const SizedBox(height: 26),
                    submitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------

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
            "Post Your Requirement",
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

  // ---------------- TOP IMAGE ----------------

  Widget _topImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        "assets/images/post.png",
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _centerTitle() {
    return Column(
      children: const [
        Text(
          "Post Your Query",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.black),
        ),
        SizedBox(height: 4),
        Text(
          "Please fill in form below and we will reach back to you",
          style: TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ---------------- COMMON UI ----------------

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      text,
      style:
      const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,color: Colors.black),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style:
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  // ---------------- INPUT ----------------

  Widget inputField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          width: double.infinity,
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
    );
  }

  // ---------------- DROPDOWN ----------------

  Widget dropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text("Select $label"),
              items: const [],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- PILLS ----------------

  Widget pillWrap(
      List<String> items, int selected, Function(int) onTap) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(items.length, (i) {
        final bool sel = selected == i;
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppColors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: sel ? AppColors.primaryColor : kBorder),
            ),
            child: Text(
              items[i],
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,color: Colors.black),
            ),
          ),
        );
      }),
    );
  }

  // ---------------- POSSESSION (ONE LINE) ----------------

  Widget possessionRow() {
    return Row(
      children: [
        Expanded(
          child: _possessionPill(
            "Ready To Move",
            possessionIndex == 0,
                () => setState(() => possessionIndex = 0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _possessionPill(
            "Under Construction",
            possessionIndex == 1,
                () => setState(() => possessionIndex = 1),
          ),
        ),
      ],
    );
  }

  Widget _possessionPill(
      String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? AppColors.primaryColor : kBorder),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TWO INPUT ROW ----------------

  Widget twoInputRow(String a, String b) {
    return Row(
      children: [
        Expanded(child: inputField(a)),
        const SizedBox(width: 12),
        Expanded(child: inputField(b)),
      ],
    );
  }

  // ---------------- SUBMIT ----------------

  Widget submitButton() {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text(
          "Submit",
          style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.black),
        ),
      ),
    );
  }
}
