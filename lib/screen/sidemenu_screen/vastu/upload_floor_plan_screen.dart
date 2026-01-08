import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_vaastu_analysis_screen.dart';

class UploadFloorPlanScreen extends StatelessWidget {
  const UploadFloorPlanScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        // Navigate to AI chat screen with the image
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AiVaastuAnalysisScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black54, size: 22),
            onPressed: () {
              // refresh / reset logic
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

            const SizedBox(height: 24),

              // TITLE
              const Text(
                "Upload Your Floor Plan",
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

            const SizedBox(height: 12),

              // SUBTITLE
              const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                "Please provide a high-quality image of your\nfloor plan for the most accurate Vaastu\nanalysis",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontSize: 14,
                    color: Colors.black54,
                  height: 1.5,
                  ),
                ),
              ),

            const SizedBox(height: 24),

              // ================= INSTRUCTIONS CARD =================
            Container(
                  width: double.infinity,
              padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                color: const Color(0xFFF8FBFE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD6F4E6),
                  width: 1.5,
                ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                          size: 20, color: Color(0xFF34F3A3)),
                      SizedBox(width: 8),
                          Text(
                            "INSTRUCTIONS",
                            style: TextStyle(
                              fontSize: 12,
                          fontWeight: FontWeight.w700,
                              color: Color(0xFF34F3A3),
                          letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                  SizedBox(height: 14),
                      _InstructionRow("Upload JPG / PNG / PDF"),
                  SizedBox(height: 8),
                      _InstructionRow("Ensure clear room boundaries"),
                    ],
                ),
              ),

            const Spacer(),

              // ================= ACTION CARDS =================
            _UploadActionCard(
                  icon: Icons.upload_file_outlined,
                  title: "Upload from Device",
                  subtitle: "FROM GALLERY OR FILES",
              onTap: () => _pickImage(context, ImageSource.gallery),
              ),

            const SizedBox(height: 16),

            _UploadActionCard(
                  icon: Icons.camera_alt_outlined,
                  title: "Take Photo",
                  subtitle: "USE YOUR CAMERA",
              onTap: () => _pickImage(context, ImageSource.camera),
              ),

            const SizedBox(height: 32),
            ],
          ),
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
            size: 20, color: Color(0xFF34F3A3)),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FBFE),
            borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFFBDF2DE),
              width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
                height: 56,
                width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF6),
                  borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFBDF2DE),
                    width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                  size: 26,
                color: const Color(0xFF34F3A3),
              ),
            ),

              const SizedBox(width: 16),
              Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                        fontSize: 16,
                    fontWeight: FontWeight.w600,
                        color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                  ),
                ),
              ],
                ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

