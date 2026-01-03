import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

class VaastuResultScreen extends StatelessWidget {
  const VaastuResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Vastu AI Expert",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

            const SizedBox(height: 16),

            // ================= SCORE CARD =================
            _scoreCard(),

            const SizedBox(height: 16),

            // ================= DIRECTIONAL ANALYSIS =================
            _directionalAnalysis(),

            const SizedBox(height: 16),

            // ================= ROOM ANALYSIS =================
            _roomAnalysis(),

            const SizedBox(height: 24),

            // ================= CTA =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Improve Vaastu Score",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                OutlineActionCard(
                  icon: Icons.auto_fix_high_outlined,
                  label: "Ask Vaastu AI",
                  onTap: () {
                    // navigate to AI chat
                  },
                ),
                const SizedBox(width: 12),
                OutlineActionCard(
                  icon: Icons.history,
                  label: "My Reports",
                  onTap: () {
                    // navigate to reports
                  },
                ),
              ],
            ),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= SCORE CARD =================
  Widget _scoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Overall Vaastu Score",
                  style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "40",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                          color: Colors.black
                      ),
                    ),
                    Text(
                      "/100",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  "Your home shows moderate compliance.\nReview suggestions below for improvements.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          // CIRCULAR INDICATOR
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: 0.4,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFE6E6E6),
                  valueColor: const AlwaysStoppedAnimation(
                    Color(0xFF34F3A3),
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    "Active users%",
                    style: TextStyle(fontWeight: FontWeight.w500,fontSize:8),
                  ),
                  const Text(
                    "40%",
                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 30),
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }

  // ================= DIRECTIONAL ANALYSIS =================
  Widget _directionalAnalysis() {
    return _sectionCard(
      title: "Directional Analysis",
      child: Column(
        children: const [
          _DirRow("North", "Water Elements", Colors.blue),
          _DirRow("East", "Great entrance", Colors.green),
          _DirRow("South", "Needs attention", Colors.orange),
          _DirRow("West", "Adequate", Colors.green),
          _DirRow("Northeast", "Optimal pooja", Colors.green),
          _DirRow("Southeast", "Kitchen correct", Colors.green),
          _DirRow("Southwest", "Master bedroom", Colors.green),
          _DirRow("Northwest", "Improve", Colors.orange),
        ],
      ),
    );
  }

  // ================= ROOM ANALYSIS =================
  Widget _roomAnalysis() {
    return _sectionCard(
      title: "Room Analysis",
      child: Column(
        children: const [
          _RoomBar("Main Entrance", "East", 0.85),
          _RoomBar("Kitchen", "Southeast", 0.75),
          _RoomBar("Bedroom", "Southwest", 0.80),
          _RoomBar("Living Room", "Northeast", 0.70),
        ],
      ),
    );
  }

  // ================= COMMON =================
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.black)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

}

class OutlineActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OutlineActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF34F3A3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: const Color(0xFF34F3A3),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                      color: Colors.black
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ================= SMALL WIDGETS =================

class _DirRow extends StatelessWidget {
  final String dir;
  final String text;
  final Color color;
  const _DirRow(this.dir, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text("$dir - ",
              style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomBar extends StatelessWidget {
  final String room;
  final String dir;
  final double value;

  const _RoomBar(this.room, this.dir, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$room ",
                    style:
                    const TextStyle(fontWeight: FontWeight.w600,color: Colors.black)),
                Text(
                  dir,
                  style:
                  const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation(
                    value >= 0.8
                        ? Colors.green
                        : value >= 0.7
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${(value * 100).round()}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
