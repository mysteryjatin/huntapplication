import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';

import 'articles_details_screen.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _appBar(context),

              const SizedBox(height: 20),

              _introCard(),

              const SizedBox(height: 25),

              Text(
                "Latest Articles",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              _articleCard(
                img: "assets/images/chalneparthner.png",
                date: "May 5, 2021",
                title: "Article on Investment in Mathura & Vrindavan",
                description:
                "Full description for Mathura & Vrindavan investment...",
                onTap: () {
                  _openDetails(
                    context,
                    "assets/images/chalneparthner.png",
                    "May 5, 2021",
                    "Article on Investment in Mathura & Vrindavan",
                    "Full description for Mathura & Vrindavan investment...",
                  );
                },
              ),

              _articleCard(
                img: "assets/images/noidasale.png",
                date: "May 5, 2021",
                title: "Technology Reshaping Construction Sector",
                description:
                "Full description for Technology reshaping sector...",
                onTap: () {
                  _openDetails(
                    context,
                    "assets/images/noidasale.png",
                    "May 5, 2021",
                    "Technology Reshaping Construction Sector",
                    "Full description for Technology reshaping sector...",
                  );
                },
              ),

              _articleCard(
                img: "assets/images/chalneparthner.png",
                date: "May 4, 2021",
                title: "Article on Investment in Zirakpur",
                description: "Full description about Zirakpur investment...",
                onTap: () {
                  _openDetails(
                    context,
                    "assets/images/chalneparthner.png",
                    "May 4, 2021",
                    "Article on Investment in Zirakpur",
                    "Full description about Zirakpur investment...",
                  );
                },
              ),

              _articleCard(
                img: "assets/images/noidasale.png",
                date: "May 3, 2021",
                title: "Article on Investment in Shimla",
                description: "Full description about Shimla investment...",
                onTap: () {
                  _openDetails(
                    context,
                    "assets/images/noidasale.png",
                    "May 3, 2021",
                    "Article on Investment in Shimla",
                    "Full description about Shimla investment...",
                  );
                },
              ),

              _articleCard(
                img: "assets/images/noidasale.png",
                date: "May 2, 2021",
                title: "Article on Investment in Rampur",
                description: "Full description about Rampur investment...",
                onTap: () {
                  _openDetails(
                    context,
                    "assets/images/noidasale.png",
                    "May 2, 2021",
                    "Article on Investment in Rampur",
                    "Full description about Rampur investment...",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // OPEN DETAILS SCREEN
  // ------------------------------------------------------------
  void _openDetails(
      BuildContext context,
      String img,
      String date,
      String title,
      String description,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailsScreen(
          title: title,
          image: img,
          date: date,
          description: description,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INTRO CARD
  // ------------------------------------------------------------
  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardbg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Articles",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '“Little knowledge is a dangerous thing” – Alexander Pope\n\n'
                'Investing in Real Estate is a big decision and we want you to invest in the right property. '
                'Hunt Property provides articles on city overviews, infrastructure, and government policies '
                'to help you make informed investment decisions.\n\n'
                'Do not just believe what you hear, be self aware!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ARTICLE CARD (FIXED ALIGNMENT)
  // ------------------------------------------------------------
  Widget _articleCard({
    required String img,
    required String date,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final bool isNetwork = img.startsWith("http");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardbg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: isNetwork
                  ? Image.network(img,
                  width: 100, height: 100, fit: BoxFit.cover)
                  : Image.asset(img,
                  width: 100, height: 100, fit: BoxFit.cover),
            ),

            const SizedBox(width: 14),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Read more",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            /// SHARE
            const SizedBox(width: 6),
            const Icon(
              Icons.share,
              size: 20,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// CUSTOM APP BAR (CENTERED TITLE)
// ------------------------------------------------------------
Widget _appBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardbg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.black,
            ),
          ),
        ),

        const Spacer(),

        const Text(
          "Articles",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),

        const Spacer(),
      ],
    ),
  );
}
