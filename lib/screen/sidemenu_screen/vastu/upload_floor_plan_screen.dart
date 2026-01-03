import 'package:flutter/material.dart';

class UploadFloorPlanScreen extends StatelessWidget {
  const UploadFloorPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Upload Floor Plan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.refresh, color: Colors.grey),
          )
        ],
      ),

      // BODY
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 12),

              const Text(
                "Upload Your Floor Plan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              const Text(
                "Please provide a high-quality image of your\n"
                    "floor plan for the most accurate Vaastu\n"
                    "analysis",
                style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
              ),

              const SizedBox(height: 18),

              // INSTRUCTIONS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FAFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD7EAF8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, size: 18, color: Color(0xFF2EDAA3)),
                        SizedBox(width: 6),
                        Text(
                          "INSTRUCTIONS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2EDAA3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _instructionRow("Upload JPG / PNG / PDF"),
                    const SizedBox(height: 8),
                    _instructionRow("Ensure clear room boundaries"),
                  ],
                ),
              ),

              const Spacer(),

              // UPLOAD FROM DEVICE
              _uploadCard(
                icon: Icons.upload_file,
                title: "Upload from Device",
                subtitle: "FROM GALLERY OR FILES",
                onTap: () {
                  // TODO: open gallery / file picker
                  debugPrint("Upload from device");
                },
              ),

              const SizedBox(height: 14),

              // TAKE PHOTO
              _uploadCard(
                icon: Icons.camera_alt_outlined,
                title: "Take Photo",
                subtitle: "USE YOUR CAMERA",
                onTap: () {
                  // TODO: open camera
                  debugPrint("Take photo");
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

    );
  }

  // --------- WIDGETS ---------

  static Widget _instructionRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 18, color: Color(0xFF2EDAA3)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  static Widget _uploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2EDAA3)),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
