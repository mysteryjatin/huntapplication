import 'package:flutter/material.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/upload_floor_plan_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';

import 'ai_vaastu_analysis_new_screen.dart';
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 4),

            // ================= TOP CARD =================
            _checkHomeHarmonyCard(context),

            const SizedBox(height: 28),

            // ================= HOW IT WORKS =================
            const Text(
              "How it works",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            _StepTile(
              icon: Icons.description_outlined,
              text: "Upload your property floor plan or drawing",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AiVaastuAnalysisNewScreen(),
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
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => const AiVaastuAnalysisScreen(),
              //     ),
              //   );
              // },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ================= TOP CARD =================
  Widget _checkHomeHarmonyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [

          // DECORATIVE CIRCLE RINGS
          Positioned(
            right: -20,
            top: 10,
            child: Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBEF4E3).withOpacity(0.3),
                  width: 20,
                ),
              ),
            ),
          ),

          Positioned(
            right: 10,
            top: 30,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9EE8D1).withOpacity(0.5),
                  width: 15,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // AI POWERED CHIP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "AI POWERED",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Check Home Harmony",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Get expert Vaastu compliance score and\nremedies without expensive consultation.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

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
                  const SizedBox(width: 14),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5F5EE),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFBDF2DE),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: const Color(0xFF34F3A3),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.3,
                  ),
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: const Color(0xFF34F3A3).withOpacity(0.1),
          highlightColor: const Color(0xFF34F3A3).withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBDF2DE),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF34F3A3),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
