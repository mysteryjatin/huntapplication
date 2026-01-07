import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  /// Generate Vastu PDF report
  Future<Map<String, dynamic>> generateVastuReport({
    required int score,
    required List<dynamic> directions,
    required List<dynamic> rooms,
    required String fullAnalysis,
    required Map<String, String> roomSelections,
  }) async {
    try {
      final pdf = pw.Document();

      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              _buildHeader(score),
              pw.SizedBox(height: 20),

              // Date
              _buildDate(),
              pw.SizedBox(height: 30),

              // Overall Score Card
              _buildScoreCard(score),
              pw.SizedBox(height: 20),

              // Room Selections
              _buildRoomSelections(roomSelections),
              pw.SizedBox(height: 20),

              // Directional Analysis
              _buildDirectionalAnalysis(directions),
              pw.SizedBox(height: 20),

              // Room Analysis
              if (rooms.isNotEmpty) _buildRoomAnalysis(rooms),
              if (rooms.isNotEmpty) pw.SizedBox(height: 20),

              // Full AI Analysis
              _buildFullAnalysis(fullAnalysis),

              // Footer
              pw.SizedBox(height: 30),
              _buildFooter(),
            ];
          },
        ),
      );

      // Save PDF
      final output = await _savePdf(pdf);
      return {
        'success': true,
        'path': output,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  pw.Widget _buildHeader(int score) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FBFE'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Vastu Analysis Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'AI-Powered Vaastu Shastra Analysis',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#34F3A3'),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'AI POWERED',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDate() {
    final now = DateTime.now();
    final formatter = DateFormat('MMMM dd, yyyy - hh:mm a');
    return pw.Text(
      'Generated: ${formatter.format(now)}',
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.grey600,
      ),
    );
  }

  pw.Widget _buildScoreCard(int score) {
    String status;
    PdfColor statusColor;
    
    if (score >= 80) {
      status = 'EXCELLENT';
      statusColor = PdfColor.fromHex('#34F3A3');
    } else if (score >= 60) {
      status = 'GOOD';
      statusColor = PdfColor.fromHex('#34F3A3');
    } else if (score >= 40) {
      status = 'AVERAGE';
      statusColor = PdfColor.fromHex('#FFA726');
    } else {
      status = 'NEEDS WORK';
      statusColor = PdfColors.red;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FBFE'),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E5F0F8')),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Overall Vaastu Score',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    '$score',
                    style: pw.TextStyle(
                      fontSize: 48,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    '/100',
                    style: const pw.TextStyle(
                      fontSize: 20,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: pw.BoxDecoration(
              color: statusColor,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              status,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRoomSelections(Map<String, String> roomSelections) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E5F0F8')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Room Placements',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...roomSelections.entries.map((entry) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '• ${entry.key}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    entry.value,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#34F3A3'),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildDirectionalAnalysis(List<dynamic> directions) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E5F0F8')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Directional Analysis',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...directions.map((dir) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    margin: const pw.EdgeInsets.only(top: 4, right: 8),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.green,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '${dir.direction} - ${dir.description}',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildRoomAnalysis(List<dynamic> rooms) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E5F0F8')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Room Analysis',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...rooms.map((room) {
            final score = (room.score * 100).round();
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            room.name,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            room.direction,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      pw.Text(
                        '$score/100',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    height: 6,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey300,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.FractionallySizedBox(
                      alignment: pw.Alignment.centerLeft,
                      widthFactor: room.score,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: score >= 80
                              ? PdfColors.green
                              : score >= 60
                                  ? PdfColor.fromHex('#FFA726')
                                  : PdfColors.red,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildFullAnalysis(String analysis) {
    // Clean up the analysis text
    final cleanedAnalysis = analysis
        .replaceAll('**', '')
        .replaceAll('###', '')
        .replaceAll('##', '');

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E5F0F8')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Detailed AI Analysis',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            cleanedAnalysis,
            style: const pw.TextStyle(
              fontSize: 10,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FBFE'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This report is generated by AI-powered Vastu analysis',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'For best results, consult with a professional Vastu consultant',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _savePdf(pw.Document pdf) async {
    final output = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${output.path}/vastu_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<void> openPdf(String path) async {
    await OpenFile.open(path);
  }
}

