import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

class AiVaastuAnalysisScreen extends StatelessWidget {
  const AiVaastuAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFE),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        centerTitle: true,
        title: const Text(
          "Ai Vaastu Analysis",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [

                  _chatBubble(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "I'm your personal AI Vaastu consultant. I'll guide you step-by-step to analyze your home.",
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "How This Works (5–7 minutes total)",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text("• Phase 1: Direction Setup",
                            style: TextStyle(fontSize: 12)),
                        Text("• Phase 2: Room Mapping",
                            style: TextStyle(fontSize: 12)),
                        Text("• Phase 3: Vaastu Analysis",
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  _chatBubble(
                    border: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Phase 1: Direction Setup ⏱",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text("Great! I can see your floor plan.",
                            style: TextStyle(fontSize: 12)),
                        SizedBox(height: 6),
                        Text(
                          "Before we analyze, please tell me which direction is NORTH in your image.",
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primaryColor),
                        ),
                        SizedBox(height: 4),
                        Text("👉 Select the North direction below:",
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  // ✅ FIXED: now also a chat bubble
                  _chatBubble(
                    border: true,
                    child: _northSelectionCard(),
                  ),

                  _chatBubble(
                    border: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Analyzing with North at Top of image ⏱",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Processing: Detecting rooms and analyzing structure.",
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primaryColor),
                        ),
                        SizedBox(height: 4),
                        Text("Time: This will take about 10 seconds",
                            style: TextStyle(fontSize: 12)),
                        SizedBox(height: 4),
                        Text("Next: We'll show you the detected rooms",
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  _summaryCard(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          /// INPUT BAR
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border:
                      Border.all(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      "Ask anything about Vaastu...",
                      style:
                      TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "Send",
                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMON =================

  static Widget _aiAvatar() {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      height: 28,
      width: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F1F1),
      ),
      child: const Icon(Icons.psychology,
          size: 18, color: Colors.brown),
    );
  }

  static Widget _chatBubble({required Widget child, bool border = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aiAvatar(),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: border
                      ? Border.all(color: AppColors.primaryColor)
                      : null,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= NORTH CARD =================

  Widget _northSelectionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/images/floor_plan.png",
                height: 54,
                width: 54,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Where is North in your image?",
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Select the side of the image that faces North",
                    style: TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            _NorthBtn("Top", "North is at the top",
                Icons.arrow_upward),
            SizedBox(width: 10),
            _NorthBtn("Right", "North is at the right",
                Icons.arrow_forward),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            _NorthBtn("Bottom", "North is at the bottom",
                Icons.arrow_downward),
            SizedBox(width: 10),
            _NorthBtn("Left", "North is at the left",
                Icons.arrow_back),
          ],
        ),
      ],
    );
  }

  static Widget _summaryCard() {
    return _chatBubble(
      border: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Your Vaastu Summary Report ✅",
            style:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Summary\nThe layout has a well-placed bedroom in the South-West, which is ideal. However, the kitchen and toilet placements need attention.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 8),
          Text("Vaastu Score: 75/100",
              style: TextStyle(
                  fontSize: 12, color: AppColors.primaryColor)),
          SizedBox(height: 6),
          Text("Critical Issues Identified: 1",
              style: TextStyle(fontSize: 12, color: Colors.red)),
          Text("Positive Aspects: 0",
              style: TextStyle(
                  fontSize: 12, color: AppColors.primaryColor)),
        ],
      ),
    );
  }
}

// ================= BUTTON =================

class _NorthBtn extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _NorthBtn(this.title, this.subtitle, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
