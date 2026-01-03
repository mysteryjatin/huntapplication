import 'package:flutter/material.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/upload_floor_plan_screen.dart';

import 'ai_vaastu_analysis_screen.dart';

class VastuAiExpertScreen extends StatelessWidget {
  const VastuAiExpertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Vastu AI Expert",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 8),

              /// MAIN CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F9FF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: Stack(
                  children: [

                    /// GREEN RING
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFBDF2DE),
                            width: 12,
                          ),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// AI POWERED
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34F3A3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "AI POWERED",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Check Home Harmony",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Get expert Vaastu compliance score and remedies without expensive consultation.",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            _actionBtn(Icons.description_outlined, "Scan Plan"),
                            const SizedBox(width: 12),
                            _actionBtn(Icons.map_outlined, "Manual Map"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                "How it works",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 14),

            _stepTile(
              Icons.upload_file_outlined,
              "Upload your property floor plan or drawing",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadFloorPlanScreen(),
                  ),
                );
              },
            ),

            _stepTile(Icons.explore_outlined,
                  "Align the North direction for accuracy",),
              _stepTile(Icons.auto_graph_outlined,
                  "AI analyzes every corner and calculates score",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiVaastuAnalysisScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _actionBtn(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEF3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF34F3A3)),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  static Widget _stepTile(
      IconData icon,
      String text, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4FAFE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF34F3A3)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

