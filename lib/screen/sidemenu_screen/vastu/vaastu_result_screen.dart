import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/pdf_report_service.dart';
import 'ai_vaastu_analysis_screen.dart';

class VaastuResultScreen extends StatefulWidget {
  final String aiAnalysis;
  final Map<String, String> roomSelections;

  const VaastuResultScreen({
    super.key,
    required this.aiAnalysis,
    required this.roomSelections,
  });

  @override
  State<VaastuResultScreen> createState() => _VaastuResultScreenState();
}

class _VaastuResultScreenState extends State<VaastuResultScreen> {
  late VastuAnalysisData _analysisData;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _analysisData = _parseAIAnalysis(widget.aiAnalysis);
  }

  VastuAnalysisData _parseAIAnalysis(String analysis) {
    // Parse the AI response to extract structured data
    int score = 0;
    List<DirectionData> directions = [];
    List<RoomScore> rooms = [];
    List<String> criticalIssues = [];
    List<String> positiveAspects = [];
    List<String> recommendations = [];

    // Extract overall score
    final scoreRegex = RegExp(r'(\d+)\s*\/\s*100');
    final scoreMatch = scoreRegex.firstMatch(analysis);
    if (scoreMatch != null) {
      score = int.tryParse(scoreMatch.group(1) ?? '0') ?? 0;
    }

    // Extract directional analysis
    final directionLines = analysis.split('\n').where((line) =>
        (line.contains('North') ||
            line.contains('East') ||
            line.contains('South') ||
            line.contains('West')) &&
        (line.contains('-') || line.contains(':')));

    for (var line in directionLines) {
      final parts = line.split(RegExp(r'[-:]'));
      if (parts.length >= 2) {
        final direction = parts[0].replaceAll('•', '').trim();
        final description = parts[1].trim();
        final status = _determineStatus(description);
        
        if (direction.isNotEmpty && 
            !directions.any((d) => d.direction == direction)) {
          directions.add(DirectionData(direction, description, status));
        }
      }
    }

    // Extract room scores
    final roomScoreRegex = RegExp(r'([A-Za-z\s]+)[:\(].*?(\d+)\s*\/\s*100');
    final roomMatches = roomScoreRegex.allMatches(analysis);
    for (var match in roomMatches) {
      final roomName = match.group(1)?.trim() ?? '';
      final roomScore = int.tryParse(match.group(2) ?? '0') ?? 0;
      if (roomName.isNotEmpty) {
        rooms.add(RoomScore(
          roomName,
          widget.roomSelections[roomName] ?? 'Unknown',
          roomScore / 100.0,
        ));
      }
    }

    // Extract issues, aspects, and recommendations
    final sections = analysis.split('\n\n');
    for (var section in sections) {
      if (section.contains('Critical') || section.contains('Issues')) {
        criticalIssues = _extractBulletPoints(section);
      } else if (section.contains('Positive') || section.contains('Aspects')) {
        positiveAspects = _extractBulletPoints(section);
      } else if (section.contains('Recommendation')) {
        recommendations = _extractBulletPoints(section);
      }
    }

    return VastuAnalysisData(
      score: score,
      directions: directions.isNotEmpty ? directions : _getDefaultDirections(),
      rooms: rooms.isNotEmpty ? rooms : _getDefaultRooms(),
      criticalIssues: criticalIssues,
      positiveAspects: positiveAspects,
      recommendations: recommendations,
      fullAnalysis: analysis,
    );
  }

  Color _determineStatus(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('good') ||
        lower.contains('correct') ||
        lower.contains('optimal') ||
        lower.contains('ideal') ||
        lower.contains('excellent')) {
      return const Color(0xFF34F3A3);
    } else if (lower.contains('need') ||
        lower.contains('improve') ||
        lower.contains('attention') ||
        lower.contains('caution')) {
      return const Color(0xFFFFA726);
    } else {
      return Colors.blue;
    }
  }

  List<String> _extractBulletPoints(String text) {
    final lines = text.split('\n');
    return lines
        .where((line) =>
            line.trim().startsWith('•') ||
            line.trim().startsWith('-') ||
            line.trim().startsWith('*'))
        .map((line) => line.replaceAll(RegExp(r'^[•\-*]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<DirectionData> _getDefaultDirections() {
    return [
      DirectionData("North", "Water Elements", Colors.blue),
      DirectionData("East", "Good placement", const Color(0xFF34F3A3)),
      DirectionData("South", "Needs attention", const Color(0xFFFFA726)),
      DirectionData("West", "Adequate", const Color(0xFF34F3A3)),
      DirectionData("Northeast", "Optimal", const Color(0xFF34F3A3)),
      DirectionData("Southeast", "Correct", const Color(0xFF34F3A3)),
      DirectionData("Southwest", "Well positioned", const Color(0xFF34F3A3)),
      DirectionData("Northwest", "Improve", const Color(0xFFFFA726)),
    ];
  }

  List<RoomScore> _getDefaultRooms() {
    return widget.roomSelections.entries.map((entry) {
      return RoomScore(entry.key, entry.value, 0.75);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
          "Vastu AI Expert",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ================= SCORE CARD =================
            _scoreCard(),

            const SizedBox(height: 20),

            // ================= DIRECTIONAL ANALYSIS =================
            _directionalAnalysis(),

            const SizedBox(height: 20),

            // ================= ROOM ANALYSIS =================
            if (_analysisData.rooms.isNotEmpty) _roomAnalysis(),

            const SizedBox(height: 28),

            // ================= CTA =================
            SizedBox(
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
                onPressed: _openChatWithContext,
                child: const Text(
                  "Improve Vaastu Score",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                OutlineActionCard(
                  icon: Icons.chat_bubble_outline,
                  label: "Ask Vaastu AI",
                  onTap: _openFreshChat,
                ),
                const SizedBox(width: 14),
                OutlineActionCard(
                  icon: Icons.picture_as_pdf_outlined,
                  label: "My Reports",
                  isLoading: _isGeneratingPdf,
                  onTap: _generatePdfReport,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _openChatWithContext() {
    // Open chat with current analysis as context
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AiVaastuAnalysisScreen(
          initialContext: 'I have received my Vastu analysis report. I want to improve my Vaastu score. Can you provide detailed remedies and suggestions?',
        ),
      ),
    );
  }

  void _openFreshChat() {
    // Open fresh chat without context
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AiVaastuAnalysisScreen(),
      ),
    );
  }

  Future<void> _generatePdfReport() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfService = PdfReportService();
      final result = await pdfService.generateVastuReport(
        score: _analysisData.score,
        directions: _analysisData.directions,
        rooms: _analysisData.rooms,
        fullAnalysis: _analysisData.fullAnalysis,
        roomSelections: widget.roomSelections,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Report saved: ${result['path']}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                pdfService.openPdf(result['path']);
              },
            ),
          ),
        );
      } else {
        throw Exception(result['error'] ?? 'Failed to generate PDF');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  Widget _scoreCard() {
    final score = _analysisData.score;
    final percentage = score / 100.0;
    
    String statusText;
    if (score >= 80) {
      statusText = "EXCELLENT";
    } else if (score >= 60) {
      statusText = "GOOD";
    } else if (score >= 40) {
      statusText = "AVERAGE";
    } else {
      statusText = "NEEDS WORK";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5F0F8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Overall Vaastu Score",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$score",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                      "/100",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  score >= 70
                      ? "Your home shows good compliance.\nKeep up the positive energy!"
                      : score >= 50
                          ? "Your home shows moderate compliance.\nReview suggestions for improvements."
                          : "Your home needs attention.\nFollow remedies to improve harmony.",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                  height: 120,
                  width: 120,
                child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFE8E8E8),
                    valueColor: AlwaysStoppedAnimation(
                      score >= 70
                          ? const Color(0xFF34F3A3)
                          : score >= 50
                              ? const Color(0xFFFFA726)
                              : const Color(0xFFFF5252),
                  ),
                ),
              ),
              Column(
                  mainAxisSize: MainAxisSize.min,
                children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                  ),
                    const SizedBox(height: 2),
                    Text(
                      "$score%",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 28,
                        height: 1,
                      ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionalAnalysis() {
    return _sectionCard(
      title: "Directional Analysis",
      child: Column(
        children: _analysisData.directions
            .map((dir) => _DirRow(dir.direction, dir.description, dir.color))
            .toList(),
      ),
    );
  }

  Widget _roomAnalysis() {
    return _sectionCard(
      title: "Room Analysis",
      child: Column(
        children: _analysisData.rooms
            .map((room) => _RoomBar(
                  room.name,
                  room.direction,
                  room.score,
                  room.score >= 0.8
                      ? Colors.green
                      : room.score >= 0.6
                          ? const Color(0xFFFFA726)
                          : Colors.red,
                ))
            .toList(),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5F0F8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// Data Models
class VastuAnalysisData {
  final int score;
  final List<DirectionData> directions;
  final List<RoomScore> rooms;
  final List<String> criticalIssues;
  final List<String> positiveAspects;
  final List<String> recommendations;
  final String fullAnalysis;

  VastuAnalysisData({
    required this.score,
    required this.directions,
    required this.rooms,
    required this.criticalIssues,
    required this.positiveAspects,
    required this.recommendations,
    required this.fullAnalysis,
  });
}

class DirectionData {
  final String direction;
  final String description;
  final Color color;

  DirectionData(this.direction, this.description, this.color);
}

class RoomScore {
  final String name;
  final String direction;
  final double score;

  RoomScore(this.name, this.direction, this.score);
}

// UI Components
class OutlineActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const OutlineActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onTap,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBDF2DE),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF34F3A3)),
                    ),
                  )
                else
                Icon(
                  icon,
                    size: 26,
                  color: const Color(0xFF34F3A3),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
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

class _DirRow extends StatelessWidget {
  final String dir;
  final String text;
  final Color color;
  const _DirRow(this.dir, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "$dir -",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomBar extends StatelessWidget {
  final String room;
  final String dir;
  final double value;
  final Color barColor;

  const _RoomBar(this.room, this.dir, this.value, this.barColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text(
                      room,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                Text(
                  dir,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${(value * 100).round()}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
