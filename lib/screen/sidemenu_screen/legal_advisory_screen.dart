import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';

class LegalAdvisoryScreen extends StatelessWidget {
  const LegalAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      /// ================= APP BAR =================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Container(

            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Text(
                  "LEGAL ADVISORY",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP CARD
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAFF),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                         Radius.circular(22),
                      ),
                      child: Image.asset(
                        "assets/images/post.png",
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LEGAL ADVISORY",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black
                            ),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            "1. Objective\n"
                                "2. At Hunt Property we believe “Knowledge is Power”. Time and again we have stated that we provide unabridged information to you. All real estate forms drafted to comply with the laws.\n"
                                "3. To save your valuable time we are providing you format of various Real Estate Legal Documents. Our Real Estate forms are designed to fit variety of real estate related needs. By having everything in writing you can minimize or all-together avoid any potential problems at a later time. These forms cover areas like:\n"
                                "• Purchasing or leasing property or land\n"
                                "• Building and construction\n"
                                "• Managing properties\n"
                                "• Transferring property\n"
                                "• Cancellation affidavits\n"
                                "4. Common Real Estate forms include:\n"
                                "• Contracts for sale and purchase\n"
                                "• Mortgage agreements and assignments\n"
                                "• Liens\n"
                                "• Contractors and construction forms\n"
                                "• Real estate disclosures\n"
                                "• Property management agreements\n"
                                "5. Although these forms are in their standard format but we suggest you to get it checked with your Legal Advisor.",
                            style: GoogleFonts.poppins(
                              fontSize: 12.2,
                              color: Colors.grey[600],
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// DOWNLOAD SECTION
            Text(
              "Download RERA Document",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _downloadTile("RERA Andhra Pradesh", "26-Dec-2020"),
            _downloadTile("ADDRESS CHANGE FORMAT", "26-Dec-2020"),
            _downloadTile("AGREEMENT TO SELL", "26-Dec-2020"),
            _downloadTile("AGREEMENT TO SELL", "26-Dec-2020"),
            _downloadTile("BROKER AGREEMENT", "26-Dec-2020"),
            _downloadTile("Builder_Buyer_Agreement Format", "26-Dec-2020"),
            _downloadTile("CANCELLATION AFFIDAVIT", "26-Dec-2020"),
            _downloadTile("CANCELLATION CHECKLIST", "26-Dec-2020"),
          ],
        ),
      ),
    );
  }

  /// ================= DOWNLOAD ROW =================
  Widget _downloadTile(String title, String date) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            date,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
          trailing: const Icon(
            Icons.download,
            color: Colors.grey,
          ),
        ),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }
}
Widget _appBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xfff1f7ff),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Colors.black),
          ),
        ),
        const SizedBox(width: 20),
        const Expanded(
          child: Text(
            "Channel Partner",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );
}
