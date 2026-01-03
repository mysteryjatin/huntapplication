import 'package:flutter/material.dart';

class AiVaastuAnalysisScreen extends StatelessWidget {
  const AiVaastuAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFE),

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Ai Vaastu Analysis",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [

          /// CHAT AREA
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [

                  _chatCard(
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
                        Text("• Phase 1: Direction Setup", style: TextStyle(fontSize: 12)),
                        Text("• Phase 2: Room Mapping", style: TextStyle(fontSize: 12)),
                        Text("• Phase 3: Vaastu Analysis", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  _chatCard(
                    border: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Phase 1: Direction Setup ⏱",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Great! I can see your floor plan.",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Before we analyze, please tell me which direction is NORTH in your image.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF2EDAA3)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "👉 Select the North direction below:",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  _directionImageCard(),

                  _directionGrid(),

                  _chatCard(
                    border: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Analyzing with North at Top of image ⏱",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Processing: Detecting rooms and analyzing structure.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF2EDAA3)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Time: This will take about 10 seconds",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Next: We'll show you the detected rooms",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  _selectDirectionGrid(),

                  _summaryCard(),
                ],
              ),
            ),
          ),

          /// INPUT BAR
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2EDAA3)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      "Ask anything about Vaastu...",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EDAA3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "Send",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ---------------- WIDGETS ----------------

  static Widget _chatCard({required Widget child, bool border = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: border
            ? Border.all(color: const Color(0xFF2EDAA3))
            : null,
      ),
      child: child,
    );
  }

  static Widget _directionImageCard() {
    return _chatCard(
      border: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Where is North in your image?",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            "Select the side of the image that faces North",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 10),
          Placeholder(fallbackHeight: 100),
        ],
      ),
    );
  }

  static Widget _directionGrid() {
    return _chatCard(
      border: true,
      child: Column(
        children: [
          Row(
            children: const [
              _DirBtn("Top"),
              _DirBtn("Right"),
            ],
          ),
          Row(
            children: const [
              _DirBtn("Bottom"),
              _DirBtn("Left"),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _selectDirectionGrid() {
    return _chatCard(
      border: true,
      child: Column(
        children: const [
          Text("Select Direction",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: 10),
          _DirectionRow("North", "Northeast"),
          _DirectionRow("South", "Southwest"),
          _DirectionRow("East", "Southeast"),
          _DirectionRow("West", "Northwest"),
        ],
      ),
    );
  }

  static Widget _summaryCard() {
    return _chatCard(
      border: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Your Vaastu Summary Report ✅",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Summary\nThe layout has a well-placed bedroom in the South-West, which is ideal. However, the kitchen and toilet placements need attention.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 6),
          Text("Vaastu Score: 75/100",
              style: TextStyle(fontSize: 12, color: Color(0xFF2EDAA3))),
          SizedBox(height: 6),
          Text("Critical Issues Identified: 1",
              style: TextStyle(fontSize: 12, color: Colors.red)),
          Text("Positive Aspects: 0",
              style: TextStyle(fontSize: 12, color: Color(0xFF2EDAA3))),
        ],
      ),
    );
  }
}

// ---------------- SMALL WIDGETS ----------------

class _DirBtn extends StatelessWidget {
  final String text;
  const _DirBtn(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2EDAA3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}

class _DirectionRow extends StatelessWidget {
  final String a, b;
  const _DirectionRow(this.a, this.b);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DirBtn(a),
        _DirBtn(b),
      ],
    );
  }
}

