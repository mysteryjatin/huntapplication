import 'package:flutter/material.dart';

class PropertyNewsScreen extends StatelessWidget {
  const PropertyNewsScreen({super.key});

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
              _newsInfoCard(),
              const SizedBox(height: 20),
              _latestNewsTitle(),
              const SizedBox(height: 6),
              _latestNewsList(),
              const SizedBox(height: 100),
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
                color: Color(0xfff1f7ff),
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
            "Property News",
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

  // ------------------------------------------------------------
  // TOP INFO CARD
  // ------------------------------------------------------------
  Widget _newsInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff0f6ff),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "NEWS",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "At Hunt Property we put our clients first and foremost. On one hand "
                "where our team is capable enough to execute any task irrespective "
                "of the complication on their own but at the same time we also "
                "believe that educating our clients about the industry they are "
                "investing in is also paramount. We have created a platform for our "
                "users so that you remain informed and updated. Here you will get "
                "information about various day to day happening in the real estate sector.",
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LATEST NEWS TITLE
  // ------------------------------------------------------------
  Widget _latestNewsTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        "LATEST NEWS",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NEWS LIST
  // ------------------------------------------------------------
  Widget _latestNewsList() {
    final news = [
      {
        "image": "assets/images/noidasale.png",
        "date": "January 11, 2025",
        "title": "YEIDA Unveils New Residential Plot Scheme...",
      },
      {
        "image": "assets/images/noidasale.png",
        "date": "January 12, 2025",
        "title": "Great Days Ahead for Indian Real Estate",
      },
      {
        "image": "assets/images/noidasale.png",
        "date": "February 21, 2025",
        "title": "The Chintels Paradiso Crisis: A Turning",
      },
      {
        "image": "assets/images/noidasale.png",
        "date": "January 12, 2025",
        "title": "Tamil Nadu’s Real Estate: Driving India’s \$2.5...",
      },
      {
        "image": "assets/images/noidasale.png",
        "date": "January 12, 2025",
        "title": "Noida Seals Four Major Housing Projects Due...",
      },
    ];

    return Column(
      children: List.generate(news.length, (i) {
        return _newsCard(
          image: news[i]["image"]!,
          date: news[i]["date"]!,
          title: news[i]["title"]!,
        );
      }),
    );
  }

  // ------------------------------------------------------------
  // SINGLE NEWS CARD (PIXEL PERFECT)
  // ------------------------------------------------------------
  Widget _newsCard({
    required String image,
    required String date,
    required String title,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff0f6ff),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Read",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2FED9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // SHARE ICON
          const Icon(
            Icons.share,
            size: 18,
            color: Color(0xFF2FED9A),
          ),
        ],
      ),
    );
  }
}
