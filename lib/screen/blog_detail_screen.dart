import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/widget/custombottomnavbar.dart';

class BlogDetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final Color bgColor;

  const BlogDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.bgColor,
  });

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _featuredBlogCard(), // 👈 YOUR IMAGE EXACT
                    _articleContent(),
                    const SizedBox(height: 20),
                    _latestUpdatesSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: _selectedNavIndex,
      //   onItemSelected: (index) {
      //     setState(() => _selectedNavIndex = index);
      //     if (index == 0) Navigator.pop(context);
      //   },
      // ),
    );
  }

  // ----------------------------------------------------------------------
  // APP BAR
  // ----------------------------------------------------------------------
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Real Estate Insights",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // FEATURED IMAGE (EXACT SAME AS SCREENSHOT)
  // ----------------------------------------------------------------------
  Widget _featuredBlogCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: _shadowCard(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9, // 📌 Keeps proportion perfect
          child: Image.asset(
            widget.image, // 📌 HERE your image will show correctly
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // ARTICLE CONTENT CARD
  // ----------------------------------------------------------------------
  Widget _articleContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: _shadowCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _articleDate(),
          const SizedBox(height: 10),
          _articleTitle(),
          const SizedBox(height: 14),
          _articleText(
            "In a recent crackdown, the Noida Authority has begun sealing four major housing societies due to serious code violations...",
          ),
          _articleText(
            "Residents were given prior notice to vacate or meet all the listed direct conditions, confirming ongoing frustration among homeowners...",
          ),
          _articleText(
            "The government is urging current residents and potential buyers to verify all documentation and legal compliance when purchasing property...",
          ),
        ],
      ),
    );
  }

  Widget _articleDate() {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          "February 21, 2025",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _articleTitle() {
    return Text(
      widget.title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        height: 1.4,
      ),
    );
  }

  Widget _articleText(String txt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        txt,
        style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.55),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // LATEST UPDATES SECTION
  // ----------------------------------------------------------------------
  Widget _latestUpdatesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Latest Updates",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _latestCard(
            image: "assets/images/blog3.png",
            date: "January 11, 2025",
            title: "YEDA Unveils New Residential Plot Scheme...",
            color: const Color(0xFF66BB6A),
          ),
          const SizedBox(height: 12),

          _latestCard(
            image: "assets/images/blog4.png",
            date: "January 19, 2025",
            title: "Great Days Ahead for Indian Real Estate",
            color: const Color(0xFF42A5F5),
          ),
          const SizedBox(height: 12),

          _latestCard(
            image: "assets/images/blog5.png",
            date: "February 21, 2025",
            title: "The Chintels Paradiso Crisis: A Turning",
            color: const Color(0xFFEF5350),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // LATEST CARD WIDGET
  // ----------------------------------------------------------------------
  Widget _latestCard({
    required String image,
    required String title,
    required String date,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlogDetailScreen(title: title, image: image, bgColor: color),
          ),
        );
      },
      child: Container(
        height: 104,
        decoration: _shadowCard(borderRadius: 14),
        child: Row(
          children: [
            _latestImage(image, color),
            _latestText(title, date),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.share_outlined, size: 18, color: Color(0xFF2FED9A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _latestImage(String image, Color color) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
      child: Container(
        width: 100,
        height: 104,
        color: color.withOpacity(0.35),
        child: Image.asset(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
          return Icon(Icons.article, size: 35, color: color);
        }),
      ),
    );
  }

  Widget _latestText(String title, String date) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 6),
            const Text("Read", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2FED9A))),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // CARD SHADOW STYLE
  // ----------------------------------------------------------------------
  BoxDecoration _shadowCard({double borderRadius = 16}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4)),
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
      ],
    );
  }
}
