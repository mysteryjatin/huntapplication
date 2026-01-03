import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

class UploadFloorPlanScreen extends StatelessWidget {
  const UploadFloorPlanScreen({super.key});

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
          "Upload Floor Plan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {
              // refresh / reset logic
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 18),

              // TITLE
              const Text(
                "Upload Your Floor Plan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // SUBTITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Please provide a high-quality image of your floor plan for the most accurate Vaastu analysis",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ================= INSTRUCTIONS CARD =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FAFE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD6F4E6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: Color(0xFF34F3A3)),
                          SizedBox(width: 6),
                          Text(
                            "INSTRUCTIONS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF34F3A3),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _InstructionRow("Upload JPG / PNG / PDF"),
                      SizedBox(height: 6),
                      _InstructionRow("Ensure clear room boundaries"),
                    ],
                  ),
                ),
              ),

             Spacer(),

              // ================= ACTION CARDS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _UploadActionCard(
                  icon: Icons.upload_file_outlined,
                  title: "Upload from Device",
                  subtitle: "FROM GALLERY OR FILES",
                  onTap: () {
                    // open gallery / file picker
                  },
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _UploadActionCard(
                  icon: Icons.camera_alt_outlined,
                  title: "Take Photo",
                  subtitle: "USE YOUR CAMERA",
                  onTap: () {
                    // open camera
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        )

      ),


    );
  }
}

// ================= COMPONENTS =================

class _InstructionRow extends StatelessWidget {
  final String text;
  const _InstructionRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle,
            size: 18, color: Color(0xFF34F3A3)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _UploadActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UploadActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardbg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBDF2DE), // mint border
            width: 1,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.15),
          //     blurRadius: 22,
          //     offset: const Offset(0, 12),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFBDF2DE), // mint border
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 22,
                color: const Color(0xFF34F3A3),
              ),
            ),

            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

