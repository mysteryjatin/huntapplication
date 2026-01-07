import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/vaastu_result_screen.dart';
import 'package:hunt_property/services/vastu_service.dart';

class ManualMapScreen extends StatefulWidget {
  const ManualMapScreen({super.key});

  @override
  State<ManualMapScreen> createState() => _ManualMapScreenState();
}

class _ManualMapScreenState extends State<ManualMapScreen> {
  final Map<String, String> selections = {};
  final VastuService _vastuService = VastuService();
  bool _isAnalyzing = false;

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
                  onPressed: _isAnalyzing ? null : () => _analyzeManualMap(),
                  child: _isAnalyzing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
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

  Future<void> _analyzeManualMap() async {
    // Set defaults for unselected rooms
    for (var room in rooms) {
      if (!selections.containsKey(room.name)) {
        selections[room.name] = "North"; // Default
      }
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Create description of the floor plan based on selections
      final floorPlanDescription = _generateFloorPlanDescription();

      // Call AI to analyze
      final response = await _vastuService.getVastuAnalysis(
        userMessage: floorPlanDescription,
        context: 'Manual floor plan mapping',
      );

      if (response['success'] == true) {
        final analysisText = response['message'] ?? '';
        
        // Navigate to result screen with AI analysis
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VaastuResultScreen(
              aiAnalysis: analysisText,
              roomSelections: Map<String, String>.from(selections),
            ),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${response['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  String _generateFloorPlanDescription() {
    final buffer = StringBuffer();
    buffer.writeln('Please analyze this floor plan according to Vastu Shastra principles:\n');
    buffer.writeln('Room Placements and Directions:\n');

    selections.forEach((room, direction) {
      buffer.writeln('• $room: Located in $direction direction');
    });

    buffer.writeln('\nPlease provide:');
    buffer.writeln('1. **Overall Vastu Score** (out of 100) - Calculate based on room placements');
    buffer.writeln('2. **Directional Analysis** - Evaluate all 8 directions');
    buffer.writeln('3. **Room-by-Room Analysis** - Score each room placement (format: RoomName: Score/100)');
    buffer.writeln('4. **Critical Issues** - Major Vastu doshas');
    buffer.writeln('5. **Positive Aspects** - What\'s correct');
    buffer.writeln('6. **Recommendations** - Specific remedies');
    buffer.writeln('\nFormat with clear sections, emojis, and scores.');

    return buffer.toString();
  }
}

class RoomData {
  final String emoji;
  final String name;

  const RoomData(this.emoji, this.name);
}
