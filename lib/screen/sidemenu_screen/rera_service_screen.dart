import 'package:flutter/material.dart';

class ReraServicesScreen extends StatelessWidget {
  const ReraServicesScreen({super.key});

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
              const SizedBox(height: 10),
              _topCard(),
              const SizedBox(height: 20),
              _downloadTitle(),
              const SizedBox(height: 10),
              _downloadList(),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CUSTOM APP BAR
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
          const SizedBox(width: 20),
          const Expanded(
            child: Text(
              "RERA Services",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP BIG CARD WITH IMAGE + CONTENT
  // ------------------------------------------------------------
  Widget _topCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(bottom: 20,top: 10,left: 10,right: 10),
      decoration: BoxDecoration(
        color: const Color(0xffeaf3ff),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all( Radius.circular(18)),
            child: Image.asset(
              "assets/images/rera_images.png",
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "About RERA",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "Why do we need RERA?",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              _reraDescription,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RERA DESCRIPTION (BIG TEXT)
  // ------------------------------------------------------------
  static const String _reraDescription = """
1. Situations faced by property buyers before RERA:
   • Property builders advertised and sold properties based on ambiguous super built up area.
   • Buyers had to pay a booking charge in advance.
   • There was no mechanism to check the progress of the project.
   • No redressal mechanism for delayed delivery or substandard work.

2. History:
   • RERA Bill introduced in 2013.
   • Amendments passed by Rajya Sabha in 2016.

3. Registration:
   • Builders must register new projects under RERA.
   • On-going projects above 500 sqm must register.

4. Protection of buyers:
   • 70% of buyer's money must be deposited in escrow.
   • Builders must quote carpet area not super built-up area.

5. Tribunal:
   • Disputes must be resolved within 60 days.

6. Objective:
   • Bring transparency, accountability, and protect customers.
""";

  // ------------------------------------------------------------
  // DOWNLOAD TITLE
  // ------------------------------------------------------------
  Widget _downloadTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "Download RERA Document",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DOWNLOAD LIST ITEMS
  // ------------------------------------------------------------
  Widget _downloadList() {
    final docs = [
      "RERA Andhra Pradesh",
      "RERA Bihar",
      "RERA Dadra and Nagar Haveli",
      "RERA Goa",
      "RERA Haryana",
      "RERA Kerala",
      "RERA Maharashtra",
      "RERA Odisha",
    ];

    return Column(
      children: List.generate(docs.length, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xfff8f8f8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.03),
                blurRadius: 2,
              )
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  "assets/images/homeloan.png",
                  height: 35,
                  width: 35,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  docs[i],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Icon(Icons.download, size: 20, color: Colors.black),
            ],
          ),
        );
      }),
    );
  }
}
