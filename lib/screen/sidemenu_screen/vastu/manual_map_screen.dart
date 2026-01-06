import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/vaastu_result_screen.dart';

class ManualMapScreen extends StatefulWidget {
  const ManualMapScreen({super.key});

  @override
  State<ManualMapScreen> createState() => _ManualMapScreenState();
}

class _ManualMapScreenState extends State<ManualMapScreen> {
  final Map<String, String> selections = {};

  final List<String> directions = const [
    "North",
    "North-East",
    "East",
    "South-East",
    "South",
    "South-West",
    "West",
    "North-West",
  ];

  final List<RoomData> rooms = const [
    RoomData("🚪", "Main Entrance"),
    RoomData("🍳", "Kitchen"),
    RoomData("🛏️", "Master Bedroom"),
    RoomData("🛋️", "Living Room"),
    RoomData("🚿", "Toilet / Bathroom"),
    RoomData("🪔", "Puja Room"),
    RoomData("🧸", "Children's Room"),
    RoomData("🌇", "Balcony"),
  ];

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Overall Vaastu Score",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // All room cards
                  ...rooms.map((room) => _sectionCard(room.emoji, room.name)),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ================= BOTTOM BUTTON =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: AppColors.primaryColor.withOpacity(0.3),
                  ),
                  onPressed: () {
                    // Check if all rooms have selections
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VaastuResultScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Calculate Compliance Score",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION CARD =================
  Widget _sectionCard(String emoji, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5F0F8),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: directions.map((dir) {
              final isSelected = selections[title] == dir ||
                  (selections[title] == null && dir == "North");

              return InkWell(
                onTap: () {
                  setState(() {
                    selections[title] = dir;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : const Color(0xFFD6E7F2),
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Text(
                    dir,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.black : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class RoomData {
  final String emoji;
  final String name;

  const RoomData(this.emoji, this.name);
}
