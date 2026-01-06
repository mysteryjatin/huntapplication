import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/vaastu_result_screen.dart';

class FloorPlanAnalysisScreen extends StatefulWidget {
  final String imagePath;

  const FloorPlanAnalysisScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<FloorPlanAnalysisScreen> createState() => _FloorPlanAnalysisScreenState();
}

enum AnalysisPhase {
  directionSetup,
  analyzing,
  showingReport,
}

class _FloorPlanAnalysisScreenState extends State<FloorPlanAnalysisScreen> {
  AnalysisPhase _phase = AnalysisPhase.directionSetup;
  String? _selectedDirection;
  String? _selectedImageSide;

  void _selectDirection(String direction) {
    setState(() {
      _selectedDirection = direction;
    });

    // Auto-proceed to analyzing after selecting direction
    Future.delayed(const Duration(milliseconds: 500), () {
      _startAnalysis();
    });
  }

  void _startAnalysis() {
    setState(() {
      _phase = AnalysisPhase.analyzing;
    });

    // Simulate analysis duration
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        // Navigate to result screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const VaastuResultScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Ai Vaastu Analysis",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: _phase == AnalysisPhase.directionSetup
          ? _buildDirectionSetup()
          : _buildAnalyzing(),
    );
  }

  Widget _buildDirectionSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Chat bubble from AI
          _aiChatBubble(
            "I'm your personal AI Vaastu consultant. I'll guide you step-by-step to analyze your home.\n\nHow This Works (5–7 minutes total)\n• Phase 1: Direction Setup\n• Phase 2: Room Mapping\n• Phase 3: Vaastu Analysis",
          ),

          const SizedBox(height: 14),

          // Phase 1 bubble
          _aiChatBubble(
            "Phase 1: Direction Setup ✓\n\nGreat! I can see your floor plan.\n\nBefore we analyze, please tell me which direction is NORTH in your image.\n\n👇 Select the North direction below:",
            hasCheck: true,
          ),

          const SizedBox(height: 14),

          // Floor plan image with direction indicator
          _buildFloorPlanWithDirections(),

          const SizedBox(height: 14),

          // Image side selector
          _buildImageSideSelector(),

          const SizedBox(height: 14),

          // Analyzing with North card (if direction selected)
          if (_selectedDirection != null) _buildAnalyzingCard(),

          const SizedBox(height: 14),

          // Direction buttons
          _buildDirectionButtons(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large circular progress
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  ),
                  Image.asset(
                    'assets/images/ganesha_vaastu_ai.png',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              "Processing: Detecting rooms and analyzing structure...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Time: This will take about 10 seconds",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF34F3A3),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Next: We'll show you the detected rooms",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiChatBubble(String text, {bool hasCheck = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10, top: 4),
          height: 32,
          width: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF1F1F1),
          ),
          child: Image.asset(
            'assets/images/ganesha_vaastu_ai.png',
            width: 20,
            height: 20,
          ),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: hasCheck
                  ? Border.all(color: AppColors.primaryColor, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloorPlanWithDirections() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Where is North in your image?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Select the side of the image that faces North",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSideSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _imageSideButton("Top", "North is at the top", Icons.arrow_upward),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _imageSideButton("Right", "North is at the right", Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _imageSideButton(String label, String description, IconData icon) {
    final isSelected = _selectedImageSide == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedImageSide = label;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.15) : const Color(0xFFF8FBFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : const Color(0xFFE8FFF6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.black : const Color(0xFF34F3A3),
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            height: 32,
            width: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F1F1),
            ),
            child: Image.asset(
              'assets/images/ganesha_vaastu_ai.png',
              width: 20,
              height: 20,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analyzing with North at Top of image ✓",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Processing: Detecting rooms and analyzing structure...",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Time: This will take about 10 seconds",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF34F3A3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Next: We'll show you the detected rooms",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Select Direction",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _directionButton("North"),
              _directionButton("Northeast"),
              _directionButton("South"),
              _directionButton("Southeast"),
              _directionButton("East"),
              _directionButton("Southwest"),
              _directionButton("West"),
              _directionButton("Northwest"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _directionButton(String direction) {
    final isSelected = _selectedDirection == direction;
    return InkWell(
      onTap: () => _selectDirection(direction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 80) / 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xFFF8FBFE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black.withOpacity(0.1) : const Color(0xFFE8FFF6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.navigation,
                color: isSelected ? Colors.black : const Color(0xFF34F3A3),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              direction,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
