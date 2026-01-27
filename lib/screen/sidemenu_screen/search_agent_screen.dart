import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';

class SearchAgentsScreen extends StatefulWidget {
  const SearchAgentsScreen({super.key});

  @override
  State<SearchAgentsScreen> createState() => _SearchAgentsScreenState();
}

class _SearchAgentsScreenState extends State<SearchAgentsScreen> {
  int selectedChip = 0;

  final List<String> chipLabels = ["All", "Delhi", "Noida", "Bangalore"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar(context),

                const SizedBox(height: 20),

                // ------------------ CHIPS ------------------
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(chipLabels.length, (index) {
                      bool active = selectedChip == index;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedChip = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: active ? 0 : 1,
                              ),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black.withOpacity(.06),
                              //     blurRadius: 10,
                              //     offset: const Offset(0, 4),
                              //   ),
                              // ],
                            ),
                            child: Text(
                              chipLabels[index],
                              style: GoogleFonts.poppins(
                                color: active ? Colors.black : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------ LOCATION INPUT ------------------
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                       // padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardbg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Other Location",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 50,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Search",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 25),

                Text(
                  "All Agents",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 15),

                // ------------------ AGENT GRID ------------------
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,

                    // PERFECT CARD HEIGHT (NO OVERFLOW)
                    childAspectRatio:
                    (MediaQuery.of(context).size.width / 2) / 350,
                  ),
                  itemBuilder: (context, index) {
                    return _agentCard(
                      name: index == 1
                          ? "shyam"
                          : index == 2
                          ? "Manish Kadyan"
                          : "Agent",
                      address: "D-24, Uttam Nagar",
                      since: "2016",
                      dealing: "Delhi",
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ PERFECT AGENT CARD (SCREENSHOT EXACT) ------------------
  Widget _agentCard({
    required String name,
    required String address,
    required String since,
    required String dealing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:AppColors.cardbg,               // exact screenshot bg
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),    // softer wider shadow
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),

          // AVATAR EXACT MATCH
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffDDE7EF),          // exact circle color
            ),
            child: const Icon(
              Icons.person,
              size: 38,                               // exact icon size
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          // NAME
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,                            // exact size
              fontWeight: FontWeight.w700,             // bold like screenshot
              color: Colors.black,
            ),
          ),

          // ADDRESS
          Text(
            address,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 14),

          // DETAILS INFO
          Text(
            "Operating since: $since",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xff7A7A7A),          // exact grey
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Dealing in $dealing",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xff7A7A7A),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          // BUTTON EXACT MATCH
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 45,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(3),
                ),

              ),
              child: Center(
                child: Text(
                  "Contact Agent",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ------------------ APP BAR ------------------
  Widget _appBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardbg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Colors.black),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            "Search Agents",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}
