import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 16),

                  const Text(
                    "Overall Vaastu Score",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                        color: Colors.black
                    ),
                  ),

                  const SizedBox(height: 12),

                  _sectionCard("🏠", "Main Entrance"),
                  _sectionCard("🍳", "Kitchen"),
                  _sectionCard("🛏️", "Master Bedroom"),
                  _sectionCard("🛋️", "Living Room"),
                  _sectionCard("🚿", "Toilet / Bathroom"),
                  _sectionCard("🪔", "Puja Room"),
                  _sectionCard("🧸", "Children's Room"),
                  _sectionCard("🌇", "Balcony"),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // ================= BOTTOM BUTTON =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // calculate score
                },
                child: const Text(
                  "Calculate Compliance Score",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E7F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                    color: Colors.black
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: directions.map((dir) {
              final isSelected = selections[title] == dir ||
                  (selections[title] == null && dir == "North");

              return ChoiceChip(
                label: Text(dir),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selections[title] = dir;
                  });
                },
                selectedColor: AppColors.primaryColor,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.black : Colors.black54,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryColor
                        : const Color(0xFFCBD5DD),
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
