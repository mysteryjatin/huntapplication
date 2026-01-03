import 'package:flutter/material.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/upload_floor_plan_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';

import 'ai_vaastu_analysis_screen.dart';
import 'manual_map_screen.dart';

class VastuAiExpertScreen extends StatelessWidget {
  const VastuAiExpertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Vastu AI Expert",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            // ================= TOP CARD =================
            _checkHomeHarmonyCard(context),

            const SizedBox(height: 24),

            // ================= HOW IT WORKS =================
            const Text(
              "How it works",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                  color: Colors.black
              ),
            ),

            const SizedBox(height: 14),

            _StepTile(
              icon: Icons.upload_file_outlined,
              text: "Upload your property floor plan or drawing",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadFloorPlanScreen(),
                  ),
                );
              },
            ),

            _StepTile(
              icon: Icons.explore_outlined,
              text: "Align the North direction for accuracy",
            ),

            _StepTile(
              icon: Icons.auto_graph_outlined,
              text: "AI analyzes every corner and calculates score",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AiVaastuAnalysisScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= TOP CARD =================
  Widget _checkHomeHarmonyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAFF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [

          // INNER MINT RING
          Positioned(
            right: 6,
            top: 18,
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBFF3E1),
                  width: 10,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // AI POWERED CHIP
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "AI POWERED",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Check Home Harmony",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                    color: Colors.black
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Get expert Vaastu compliance score and remedies without expensive consultation.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _ActionBox(
                    icon: Icons.description_outlined,
                    label: "Scan Plan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UploadFloorPlanScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _ActionBox(
                    icon: Icons.map_outlined,
                    label: "Manual Map",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManualMapScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= STEP TILE =================
class _StepTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _StepTile({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // 👈 important
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,     // 👈 remove ripple
        highlightColor: Colors.transparent,  // 👈 remove highlight
        hoverColor: Colors.transparent,
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
                  border: Border.all(color: const Color(0xFFD6F4E6)),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF34F3A3),
                ),
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
      ),
    );
  }
}

// ================= ACTION BOX =================
class _ActionBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBox({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        //borderRadius: BorderRadius.circular(14),
        child: InkWell(
          //borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: Colors.transparent,     // 👈 remove ripple
          highlightColor: Colors.transparent,  // 👈 remove highlight
          hoverColor: Colors.transparent,
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
                Text(label, style: const TextStyle(fontSize: 13,color: Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
