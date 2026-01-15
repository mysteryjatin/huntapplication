import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/vastu_service.dart';
import 'package:hunt_property/services/pdf_report_service.dart';
import 'package:hunt_property/utils/text_formatter.dart';
import 'package:hunt_property/utils/vastu_response_parser.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/invalid_image_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/ai_vaastu_analysis_screen.dart';

class AiVaastuAnalysisNewScreen extends StatefulWidget {
  final String? imagePath;
  final String? initialContext;

  const AiVaastuAnalysisNewScreen({
    super.key,
    this.imagePath,
    this.initialContext,
  });

  static const Color kGreen = Color(0xFF2EE59D);

  @override
  State<AiVaastuAnalysisNewScreen> createState() => _AiVaastuAnalysisNewScreenState();
}

class _AiVaastuAnalysisNewScreenState extends State<AiVaastuAnalysisNewScreen> {
  final VastuService _vastuService = VastuService();
  bool _isLoading = false;
  bool _isAnalyzing = false;
  bool _analysisComplete = false;
  bool _isGeneratingPdf = false;
  String? _selectedImageSide; // Top, Right, Bottom, Left
  String? _selectedDirection; // North, Northeast, etc.
  bool _imageValidated = false;
  String? _analysisText;
  Map<String, dynamic>? _analysisData;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    
    if (widget.imagePath != null) {
      _validateImage();
    } else if (widget.initialContext != null) {
      // If coming from "Improve Vaastu Score", navigate to chat screen
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AiVaastuAnalysisScreen(
                initialContext: widget.initialContext,
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _validateImage() async {
    try {
      if (widget.imagePath == null) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final imageBytes = await File(widget.imagePath!).readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      final validationResponse = await _vastuService.validateFloorPlanImage(
        imageBase64: imageBase64,
      );

      setState(() {
        _isLoading = false;

        if (validationResponse['success'] == true && 
            validationResponse['isValid'] == true) {
          _imageValidated = true;
        } else {
          _imageValidated = false;
          _showImageValidationError(
            validationResponse['message'] ?? 
            "This doesn't appear to be a valid floor plan image. Please upload a clear floor plan image for accurate Vastu analysis."
          );
        }
      });
    } catch (e) {
      print('Image validation error: $e');
      setState(() {
        _isLoading = false;
        _imageValidated = false;
      });
      _showImageValidationError(
        "Unable to validate the image. Please ensure you've uploaded a clear floor plan image and try again."
      );
    }
  }

  void _showImageValidationError(String message) {
    if (widget.imagePath != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InvalidImageScreen(
            imagePath: widget.imagePath!,
            errorMessage: message,
          ),
        ),
      );
    }
  }

  void _selectImageSide(String side) {
    setState(() {
      _selectedImageSide = side;
    });
  }

  void _selectDirection(String direction) {
    if (_selectedImageSide == null) {
      // First select image side
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select where North is in your image first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _selectedDirection = direction;
      _isAnalyzing = true;
    });

    // Perform AI analysis
    _performAIAnalysis();
  }

  Future<void> _performAIAnalysis() async {
    try {
      Map<String, dynamic> response;

      if (widget.imagePath != null) {
        try {
          final imageBytes = await File(widget.imagePath!).readAsBytes();
          final imageBase64 = base64Encode(imageBytes);

          final northDirectionInfo = _selectedImageSide != null 
              ? '$_selectedDirection (facing $_selectedImageSide)'
              : _selectedDirection ?? 'North';

          response = await _vastuService.analyzeFloorPlanWithVision(
            imageBase64: imageBase64,
            northDirection: northDirectionInfo,
          );
        } catch (visionError) {
          print('Vision API not available, using text-based analysis: $visionError');
          
          final imageSideInfo = _selectedImageSide != null 
              ? ', and North is facing $_selectedImageSide in the image'
              : '';
          final query = '''I have uploaded a floor plan image with North direction at $_selectedDirection$imageSideInfo.

Please analyze this floor plan according to Vastu Shastra principles and provide a structured response in the following format:

**Overall Vastu Score:** [Number]/100

**Directional Analysis:**
North: [Description]
Northeast: [Description]
East: [Description]
Southeast: [Description]
South: [Description]
Southwest: [Description]
West: [Description]
Northwest: [Description]

**Room Analysis:**
[Room Name]: [Score if applicable] - [Description]
[Room Name]: [Score if applicable] - [Description]

**Critical Issues:**
- [Issue Title]: [Description]
- [Issue Title]: [Description]

**Positive Aspects:**
- [Aspect Title]: [Description]
- [Aspect Title]: [Description]

**Recommendations:**
- [Recommendation Title]: [Description]
- [Recommendation Title]: [Description]

Please ensure all 8 directions are included and format each section clearly.''';

          response = await _vastuService.getVastuAnalysis(
            userMessage: query,
            context: 'Floor plan analysis with North at $_selectedDirection',
          );
        }
      } else {
        final query = '''Please provide a general Vastu analysis with North at $_selectedDirection direction.

Please provide a structured response in the following format:

**Overall Vastu Score:** [Number]/100

**Directional Analysis:**
North: [Description]
Northeast: [Description]
East: [Description]
Southeast: [Description]
South: [Description]
Southwest: [Description]
West: [Description]
Northwest: [Description]

**Room Placement Guidelines:**
[Guideline 1]
[Guideline 2]

**Recommendations:**
- [Recommendation Title]: [Description]
- [Recommendation Title]: [Description]

Please ensure all 8 directions are included and format each section clearly.''';

        response = await _vastuService.getVastuAnalysis(
          userMessage: query,
          context: 'General Vastu analysis',
        );
      }

      setState(() {
        _isAnalyzing = false;

        if (response['success'] == true) {
          _analysisText = response['message'] ?? 'Analysis completed';
          _analysisComplete = true;
          try {
            _analysisData = _parseAnalysisData(_analysisText!);
            print('✅ Parsing successful. Score: ${_analysisData?['score']}, Directions: ${(_analysisData?['directional'] as List?)?.length ?? 0}');
          } catch (e, stackTrace) {
            print('❌ Error parsing analysis data: $e');
            print('Stack trace: $stackTrace');
            print('Analysis text length: ${_analysisText?.length ?? 0}');
            if (_analysisText != null && _analysisText!.isNotEmpty) {
              final previewLength = _analysisText!.length > 200 ? 200 : _analysisText!.length;
              if (previewLength > 0) {
                print('Analysis text preview: ${_analysisText!.substring(0, previewLength)}');
              }
            }
            
            // Set default data structure to prevent UI errors
            _analysisData = {
              'score': 0,
              'directional': _getDefaultDirections(),
              'rooms': [],
              'issues': [],
              'positive': [],
              'recommendations': [],
            };
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Analysis completed but some data could not be parsed. Showing available results.'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analysis failed: ${response['error'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _parseAnalysisData(String text) {
    final data = <String, dynamic>{};
    
    try {
      // Extract score - more robust pattern matching
      final scorePatterns = [
        RegExp(r'(\d+)\s*/\s*100', caseSensitive: false),
        RegExp(r'score[:\s]+(\d+)', caseSensitive: false),
        RegExp(r'(\d+)\s*out\s*of\s*100', caseSensitive: false),
        RegExp(r'(\d+)\s*%', caseSensitive: false),
      ];
      
      for (var pattern in scorePatterns) {
        try {
          final match = pattern.firstMatch(text);
          if (match != null && match.groupCount >= 1) {
            final scoreStr = match.group(1);
            if (scoreStr != null) {
              final score = int.tryParse(scoreStr) ?? 0;
              if (score > 0 && score <= 100) {
                data['score'] = score;
                break;
              }
            }
          }
        } catch (e) {
          print('Error matching score pattern: $e');
          continue;
        }
      }
      
      // Default score if not found
      if (!data.containsKey('score')) {
        data['score'] = 0;
      }
    } catch (e) {
      print('Error extracting score: $e');
      data['score'] = 0;
    }

    // Extract directional analysis - improved parsing
    List<Map<String, String>> directionalData = [];
    try {
      final directionalSection = _extractSection(text, [
        'Directional Analysis',
        'Direction Analysis',
        'Directions',
        '8 Directions',
        'Directional',
      ]);
      
      if (directionalSection != null) {
        directionalData = _parseDirectionalData(directionalSection);
      } else {
        // Try to extract from full text if section not found
        directionalData = _parseDirectionalData(text);
      }
      
      // Ensure we have all 8 directions - fill missing ones
      final allDirections = ['North', 'Northeast', 'East', 'Southeast', 'South', 'Southwest', 'West', 'Northwest'];
      final foundDirections = directionalData.map((d) => d['direction']?.toLowerCase() ?? '').where((d) => d.isNotEmpty).toSet();
      
      for (var dir in allDirections) {
        if (!foundDirections.contains(dir.toLowerCase()) && 
            !foundDirections.contains(dir.replaceAll('-', '').toLowerCase())) {
          directionalData.add({
            'direction': dir,
            'description': 'Analysis pending for this direction.',
          });
        }
      }
    } catch (e) {
      print('Error parsing directional data: $e');
      directionalData = _getDefaultDirections();
    }
    
    data['directional'] = directionalData;

    // Extract room analysis
    try {
      final roomSection = _extractSection(text, [
        'Room Analysis',
        'Rooms',
        'Room Placement',
        'Room Evaluation',
      ]);
      if (roomSection != null) {
        data['rooms'] = _parseRoomData(roomSection);
      } else {
        data['rooms'] = _parseRoomData(text);
      }
    } catch (e) {
      print('Error parsing room data: $e');
      data['rooms'] = [];
    }

    // Extract critical issues - improved parsing
    try {
      final issuesSection = _extractSection(text, [
        'Critical Issues',
        'Issues',
        'Dosh',
        'Doshas',
        'Vastu Doshas',
        'Problems',
        'Defects',
      ]);
      if (issuesSection != null) {
        data['issues'] = _extractItems(issuesSection, isIssue: true);
      } else {
        data['issues'] = [];
      }
    } catch (e) {
      print('Error parsing issues: $e');
      data['issues'] = [];
    }

    // Extract positive aspects
    try {
      final positiveSection = _extractSection(text, [
        'Positive Aspects',
        'Positive',
        'Strengths',
        'Good Aspects',
        'What\'s Good',
      ]);
      if (positiveSection != null) {
        data['positive'] = _extractItems(positiveSection, isPositive: true);
      } else {
        data['positive'] = [];
      }
    } catch (e) {
      print('Error parsing positive aspects: $e');
      data['positive'] = [];
    }

    // Extract recommendations
    try {
      final recommendationsSection = _extractSection(text, [
        'Recommendations',
        'Remedies',
        'Suggestions',
        'Improvements',
        'Actions',
      ]);
      if (recommendationsSection != null) {
        data['recommendations'] = _extractItems(recommendationsSection, isRecommendation: true);
      } else {
        data['recommendations'] = [];
      }
    } catch (e) {
      print('Error parsing recommendations: $e');
      data['recommendations'] = [];
    }

    return data;
  }

  String? _extractSection(String text, List<String> keywords) {
    for (var keyword in keywords) {
      // Try multiple patterns
      final patterns = [
        RegExp('$keyword[:\n]?\\s*([\\s\\S]*?)(?=\\n\\n|\\n\\*\\*[A-Z]|\\n#|\\n\\d+\\.|\\z)', caseSensitive: false),
        RegExp('$keyword[:\n]?\\s*([\\s\\S]*?)(?=\\n[A-Z][a-z]+ [A-Z]|\\*\\*|#|\\z)', caseSensitive: false),
        RegExp('$keyword[:\n]?\\s*([\\s\\S]*?)(?=\\n\\n|\\z)', caseSensitive: false),
      ];
      
      for (var regex in patterns) {
        final match = regex.firstMatch(text);
        if (match != null && match.group(1) != null) {
          final section = match.group(1)!.trim();
          if (section.length > 10) { // Only return if meaningful content
            return section;
          }
        }
      }
    }
    return null;
  }

  List<Map<String, String>> _parseDirectionalData(String section) {
    final directions = <Map<String, String>>[];
    
    try {
      final lines = section.split('\n');
      
      // Normalize direction names
      final directionMap = {
        'north-east': 'Northeast',
        'north east': 'Northeast',
        'northeast': 'Northeast',
        'south-east': 'Southeast',
        'south east': 'Southeast',
        'southeast': 'Southeast',
        'south-west': 'Southwest',
        'south west': 'Southwest',
        'southwest': 'Southwest',
        'north-west': 'Northwest',
        'north west': 'Northwest',
        'northwest': 'Northwest',
      };
      
      for (var line in lines) {
        try {
          line = line.trim();
          if (line.isEmpty) continue;
          
          // Try multiple patterns
          final patterns = [
            RegExp(r'^(North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West)[:\s-]+(.+)$', caseSensitive: false),
            RegExp(r'^(\d+\.)?\s*(North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West)[:\s-]+(.+)$', caseSensitive: false),
            RegExp(r'^\*\*(North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West)\*\*[:\s-]+(.+)$', caseSensitive: false),
          ];
          
          for (var pattern in patterns) {
            try {
              final match = pattern.firstMatch(line);
              if (match != null && match.groupCount >= 1) {
                var directionName = '';
                var description = '';
                
                // Safely extract groups
                try {
                  directionName = (match.group(2) ?? match.group(1))?.toString().trim() ?? '';
                  description = (match.group(3) ?? match.group(2))?.toString().trim() ?? '';
                } catch (e) {
                  print('Error extracting direction groups: $e');
                  continue;
                }
                
                if (directionName.isEmpty) continue;
                
                // Normalize direction name
                directionName = directionName.trim();
                if (directionName.isEmpty) continue;
                
                final normalized = directionMap[directionName.toLowerCase()];
                if (normalized != null) {
                  directionName = normalized;
                } else if (directionName.isNotEmpty) {
                  // Capitalize first letter safely
                  try {
                    if (directionName.length > 0) {
                      final firstChar = directionName[0];
                      final rest = directionName.length > 1 ? directionName.substring(1) : '';
                      directionName = firstChar.toUpperCase() + rest.toLowerCase();
                    }
                  } catch (e) {
                    print('Error normalizing direction name: $e');
                    // Use as-is if normalization fails
                  }
                }
                
                description = description.trim();
                if (description.isEmpty) {
                  description = 'Analysis for $directionName direction.';
                }
                
                // Remove markdown formatting
                description = description.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
                description = description.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
                
                directions.add({
                  'direction': directionName,
                  'description': description,
                });
                break;
              }
            } catch (e) {
              print('Error matching direction pattern: $e');
              continue;
            }
          }
        } catch (e) {
          print('Error parsing direction line: $line, error: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error in _parseDirectionalData: $e');
    }
    
    return directions;
  }

  List<Map<String, String>> _parseRoomData(String section) {
    final rooms = <Map<String, String>>[];
    
    try {
      final lines = section.split('\n');
      
      for (var line in lines) {
        try {
          line = line.trim();
          if (line.isEmpty) continue;
          
          // Remove markdown formatting
          line = line.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
          line = line.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
          
          // Try multiple patterns for room parsing
          final patterns = [
            RegExp(r'^([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance|Balcony|Master|Guest))[:\s]+(?:(\d+/\d+)[\s-]+)?(.+)$', caseSensitive: false),
            RegExp(r'^(\d+\.)?\s*([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance|Balcony|Master|Guest))[:\s]+(?:(\d+/\d+)[\s-]+)?(.+)$', caseSensitive: false),
            RegExp(r'^([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance|Balcony|Master|Guest))\s*\(([^)]+)\)[:\s]+(?:(\d+/\d+)[\s-]+)?(.+)$', caseSensitive: false),
          ];
          
          bool matched = false;
          for (var i = 0; i < patterns.length; i++) {
            try {
              final pattern = patterns[i];
              final roomMatch = pattern.firstMatch(line);
              if (roomMatch != null) {
                var roomName = '';
                var score = '';
                var description = '';
                
                // Safely extract groups based on pattern index
                try {
                  if (i == 0) {
                    // Pattern 1: roomName, score (optional), description
                    if (roomMatch.groupCount >= 1) {
                      final g1 = roomMatch.group(1);
                      if (g1 != null) roomName = g1.toString().trim();
                    }
                    if (roomMatch.groupCount >= 2) {
                      final g2 = roomMatch.group(2);
                      if (g2 != null) score = g2.toString();
                    }
                    if (roomMatch.groupCount >= 3) {
                      final g3 = roomMatch.group(3);
                      if (g3 != null) description = g3.toString().trim();
                    }
                  } else if (i == 1) {
                    // Pattern 2: number (optional), roomName, score (optional), description
                    if (roomMatch.groupCount >= 2) {
                      final g2 = roomMatch.group(2);
                      if (g2 != null) roomName = g2.toString().trim();
                    }
                    if (roomMatch.groupCount >= 3) {
                      final g3 = roomMatch.group(3);
                      if (g3 != null) score = g3.toString();
                    }
                    if (roomMatch.groupCount >= 4) {
                      final g4 = roomMatch.group(4);
                      if (g4 != null) description = g4.toString().trim();
                    }
                  } else if (i == 2) {
                    // Pattern 3: roomName, location, score (optional), description
                    String baseName = '';
                    String location = '';
                    if (roomMatch.groupCount >= 1) {
                      final g1 = roomMatch.group(1);
                      if (g1 != null) baseName = g1.toString().trim();
                    }
                    if (roomMatch.groupCount >= 2) {
                      final g2 = roomMatch.group(2);
                      if (g2 != null) location = g2.toString().trim();
                    }
                    roomName = location.isNotEmpty ? '$baseName ($location)' : baseName;
                    if (roomMatch.groupCount >= 3) {
                      final g3 = roomMatch.group(3);
                      if (g3 != null) score = g3.toString();
                    }
                    if (roomMatch.groupCount >= 4) {
                      final g4 = roomMatch.group(4);
                      if (g4 != null) description = g4.toString().trim();
                    }
                  }
                } catch (e) {
                  print('Error extracting room match groups: $e, patternIndex: $i');
                  continue;
                }
                
                if (roomName.isEmpty) continue;
                
                if (description.isEmpty) {
                  description = 'Analysis for $roomName.';
                }
                
                rooms.add({
                  'room': roomName,
                  'score': score,
                  'description': description,
                });
                matched = true;
                break;
              }
            } catch (e) {
              print('Error matching room pattern $i: $e');
              continue;
            }
          }
        } catch (e) {
          print('Error parsing room line: $line, error: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error in _parseRoomData: $e');
    }
    
    return rooms;
  }

  List<String> _extractItems(String section, {bool isIssue = false, bool isPositive = false, bool isRecommendation = false}) {
    final items = <String>[];
    final lines = section.split('\n');
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Skip section headers
      if (line.toLowerCase().contains('critical') || 
          line.toLowerCase().contains('positive') ||
          line.toLowerCase().contains('recommendation') ||
          line.toLowerCase().contains('issue') ||
          line.toLowerCase().contains('dosh')) {
        continue;
      }
      
      // Remove markdown formatting
      line = line.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
      line = line.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
      line = line.replaceAll(RegExp(r'^#{1,6}\s+'), '');
      
      String cleaned = '';
      
      if (line.startsWith('-') || line.startsWith('•') || RegExp(r'^\d+\.').hasMatch(line)) {
        cleaned = line.replaceAll(RegExp(r'^[-•\d\.]\s*'), '').trim();
      } else if (line.length > 15) {
        cleaned = line;
      }
      
      if (cleaned.isNotEmpty && cleaned.length > 10) {
        // Clean up any remaining formatting
        cleaned = cleaned.replaceAll(RegExp(r'^\*\*'), '');
        cleaned = cleaned.replaceAll(RegExp(r'\*\*$'), '');
        items.add(cleaned);
      }
    }
    
    return items;
  }

  Future<void> _generatePdfReport() async {
    if (!_analysisComplete || _analysisText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the analysis first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfService = PdfReportService();
      
      final score = _analysisData?['score'] ?? 0;

      final result = await pdfService.generateVastuReport(
        score: score,
        directions: [],
        rooms: [],
        fullAnalysis: _analysisText!,
        roomSelections: {},
      );

      if (result['success'] == true) {
        if (mounted) {
          bool shareSuccess = false;
          try {
            await pdfService.sharePdf(result['path']);
            shareSuccess = true;
          } catch (shareError) {
            print('Share error (non-critical): $shareError');
            shareSuccess = false;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                shareSuccess 
                  ? 'PDF Report generated and ready to share!'
                  : 'PDF Report generated successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () {
                  pdfService.openPdf(result['path']);
                },
              ),
            ),
          );
        }
      } else {
        throw Exception(result['error'] ?? 'Failed to generate PDF');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  void _openChatWithContext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiVaastuAnalysisScreen(
          initialContext: _analysisText != null
              ? 'I have received my Vastu analysis report. I want to improve my Vaastu score. Can you provide detailed remedies and suggestions?'
              : 'I want to ask questions about Vastu Shastra.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Ai Vaastu Analysis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🤖 AI INTRO
            ganeshAiMessageCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "I'm your personal AI Vaastu consultant. I'll guide you step-by-step to analyze your home.",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'How This Works (5–7 minutes total)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text('• Phase 1: Direction Setup'),
                  Text('• Phase 2: Room Mapping'),
                  Text('• Phase 3: Vaastu Analysis'),
                ],
              ),
            ),

            if (!_analysisComplete) ...[
              const SizedBox(height: 14),

              /// 🧭 PHASE 1 (only show if image is validated)
              if (_imageValidated && _currentImagePath != null)
                ganeshAiMessageCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Phase 1: Direction Setup ⏱️',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text('Great! I can see your floor plan.'),
                      SizedBox(height: 6),
                      Text(
                        'Before we analyze, please tell me which direction is NORTH in your image.',
                        style:
                            TextStyle(color: AppColors.primaryColor, fontSize: 12),
                      ),
                      SizedBox(height: 8),
                      Text('👇 Select the North direction below:',
                          style: TextStyle(
                              color: AppColors.primaryColor, fontSize: 12)),
                    ],
                  ),
                ),

              if (_imageValidated && _currentImagePath != null) ...[
                const SizedBox(height: 14),

                /// 🧭 WHERE IS NORTH CARD
                whereIsNorthCard(),

                if (_selectedImageSide != null) ...[
                  const SizedBox(height: 14),

                  /// ⚙️ ANALYZING STATUS (only show if analyzing)
                  if (_isAnalyzing) analyzingStatusCard(),

                  if (!_isAnalyzing) ...[
                    const SizedBox(height: 14),

                    /// 🧭 SELECT DIRECTION (8 DIRECTIONS)
                    selectDirectionCard(),
                  ],
                ],
              ],

              if (_isLoading) ...[
                const SizedBox(height: 14),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],

            if (_analysisComplete && _analysisData != null) ...[
              const SizedBox(height: 20),

              /// ⭐ OVERALL VAASTU (FULL SECTION)
              overallVaastuBorderCard(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              /// REPORT BUTTON
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FAFF), // light bluish bg
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _isGeneratingPdf ? null : _generatePdfReport,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isGeneratingPdf)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        else
                          const Icon(Icons.download, size: 20, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          'REPORT',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _isGeneratingPdf ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// ASK AI BUTTON
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AiVaastuAnalysisNewScreen.kGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _openChatWithContext,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 20, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'ASK AI',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= GANESH + AI MESSAGE BASE =================

  Widget ganeshAiMessageCard({required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/images/ganesha_vaastu_ai.png',
            height: 34, width: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AiVaastuAnalysisNewScreen.kGreen),
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  // ================= WHERE IS NORTH CARD =================

  Widget whereIsNorthCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AiVaastuAnalysisNewScreen.kGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (IMAGE + TEXT)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: 80,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _currentImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_currentImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/floor_plan.png',
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Where is North in your image?',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Select the side of the image that faces North',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// BUTTON GRID (2x2)
          Row(
            children: [
              Expanded(
                child: _NorthOptionCard(
                  title: 'Top',
                  subtitle: 'North is at the top',
                  icon: Icons.arrow_upward,
                  isSelected: _selectedImageSide == 'Top',
                  onTap: () => _selectImageSide('Top'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NorthOptionCard(
                  title: 'Right',
                  subtitle: 'North is at the right',
                  icon: Icons.arrow_forward,
                  isSelected: _selectedImageSide == 'Right',
                  onTap: () => _selectImageSide('Right'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NorthOptionCard(
                  title: 'Bottom',
                  subtitle: 'North is at the bottom',
                  icon: Icons.arrow_downward,
                  isSelected: _selectedImageSide == 'Bottom',
                  onTap: () => _selectImageSide('Bottom'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NorthOptionCard(
                  title: 'Left',
                  subtitle: 'North is at the left',
                  icon: Icons.arrow_back,
                  isSelected: _selectedImageSide == 'Left',
                  onTap: () => _selectImageSide('Left'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ANALYZING =================

  Widget analyzingStatusCard() {
    return ganeshAiMessageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyzing with North at $_selectedImageSide of image 🧭',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Processing: ',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'Detecting rooms and analyzing structure...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Time: ',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'This will take about 10 seconds',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text("Next: We'll show you the detected rooms",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= SELECT DIRECTION (8) =================

  Widget selectDirectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AiVaastuAnalysisNewScreen.kGreen),
      ),
      child: Column(
        children: [
          const Text(
            'Select Direction',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.6,
            children: [
              _DirectionTile(
                Icons.arrow_upward,
                'North',
                isSelected: _selectedDirection == 'North',
                onTap: () => _selectDirection('North'),
              ),
              _DirectionTile(
                Icons.north_east,
                'Northeast',
                isSelected: _selectedDirection == 'Northeast',
                onTap: () => _selectDirection('Northeast'),
              ),
              _DirectionTile(
                Icons.arrow_downward,
                'South',
                isSelected: _selectedDirection == 'South',
                onTap: () => _selectDirection('South'),
              ),
              _DirectionTile(
                Icons.south_west,
                'Southwest',
                isSelected: _selectedDirection == 'Southwest',
                onTap: () => _selectDirection('Southwest'),
              ),
              _DirectionTile(
                Icons.arrow_forward,
                'East',
                isSelected: _selectedDirection == 'East',
                onTap: () => _selectDirection('East'),
              ),
              _DirectionTile(
                Icons.south_east,
                'Southeast',
                isSelected: _selectedDirection == 'Southeast',
                onTap: () => _selectDirection('Southeast'),
              ),
              _DirectionTile(
                Icons.arrow_back,
                'West',
                isSelected: _selectedDirection == 'West',
                onTap: () => _selectDirection('West'),
              ),
              _DirectionTile(
                Icons.north_west,
                'Northwest',
                isSelected: _selectedDirection == 'Northwest',
                onTap: () => _selectDirection('Northwest'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= OVERALL VAASTU =================

  Widget overallVaastuBorderCard() {
    final score = _analysisData?['score'] ?? 0;
    
    // Safely convert List<dynamic> to List<Map<String, String>>
    final directionalDataRaw = _analysisData?['directional'];
    final directionalData = (directionalDataRaw is List)
        ? directionalDataRaw.map((item) {
            if (item is Map) {
              return Map<String, String>.from(item.map((key, value) => MapEntry(key.toString(), value?.toString() ?? '')));
            }
            return <String, String>{};
          }).toList()
        : <Map<String, String>>[];
    
    // Safely convert List<dynamic> to List<Map<String, String>>
    final roomDataRaw = _analysisData?['rooms'];
    final roomData = (roomDataRaw is List)
        ? roomDataRaw.map((item) {
            if (item is Map) {
              return Map<String, String>.from(item.map((key, value) => MapEntry(key.toString(), value?.toString() ?? '')));
            }
            return <String, String>{};
          }).toList()
        : <Map<String, String>>[];
    
    // Safely convert List<dynamic> to List<String>
    final issuesDataRaw = _analysisData?['issues'];
    final issuesData = (issuesDataRaw is List)
        ? issuesDataRaw.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList()
        : <String>[];
    
    // Safely convert List<dynamic> to List<String>
    final positiveDataRaw = _analysisData?['positive'];
    final positiveData = (positiveDataRaw is List)
        ? positiveDataRaw.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList()
        : <String>[];
    
    // Safely convert List<dynamic> to List<String>
    final recommendationsDataRaw = _analysisData?['recommendations'];
    final recommendationsData = (recommendationsDataRaw is List)
        ? recommendationsDataRaw.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList()
        : <String>[];

    String statusText;
    Color statusColor;
    Color bgColor;

    if (score >= 80) {
      statusText = "EXCELLENT HARMONY";
      statusColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFCFF5D6);
    } else if (score >= 60) {
      statusText = "NEEDS IMPROVEMENT HARMONY";
      statusColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFCFF5D6);
    } else {
      statusText = "NEEDS IMPROVEMENT HARMONY";
      statusColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFCFF5D6);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AiVaastuAnalysisNewScreen.kGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FBF7), // light mint bg
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP ROW
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// LEFT TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'OVERALL VASTU SCORE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$score',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '/100',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// RIGHT ICON
                          Image.asset('assets/images/overall_vastu_score_icon_opacity.png')
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// STATUS PILL
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Icon(
                  Icons.navigation,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'DIRECTIONAL ANALYSIS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Always show directional analysis (even if empty, show placeholder)
          directionalAnalysisGrid(directionalData.isNotEmpty ? directionalData : _getDefaultDirections()),
          const SizedBox(height: 20),
          // Always show room analysis section
          if (roomData.isNotEmpty) roomAnalysisSection(roomData),
          const SizedBox(height: 20),
          // Always show issues section if there are issues
          if (issuesData.isNotEmpty) roomAnalysisDoshSection(issuesData),
          const SizedBox(height: 20),
          // Always show positive aspects if available
          if (positiveData.isNotEmpty) positiveAspectsSection(positiveData),
          const SizedBox(height: 20),
          // Always show recommendations if available
          if (recommendationsData.isNotEmpty) recommendationsSection(recommendationsData),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              '"By following these Vastu principles, the energy in the house can be optimized for better harmony and prosperity."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Map<String, String>> _getDefaultDirections() {
    return [
      {'direction': 'North', 'description': 'Analysis pending.'},
      {'direction': 'Northeast', 'description': 'Analysis pending.'},
      {'direction': 'East', 'description': 'Analysis pending.'},
      {'direction': 'Southeast', 'description': 'Analysis pending.'},
      {'direction': 'South', 'description': 'Analysis pending.'},
      {'direction': 'Southwest', 'description': 'Analysis pending.'},
      {'direction': 'West', 'description': 'Analysis pending.'},
      {'direction': 'Northwest', 'description': 'Analysis pending.'},
    ];
  }

  Widget directionalAnalysisGrid(List<Map<String, String>> directions) {
    // Map direction names to icon paths
    final directionIcons = {
      'North': 'assets/images/north.png',
      'Northeast': 'assets/images/north_east.png',
      'North-East': 'assets/images/north_east.png',
      'East': 'assets/images/east.png',
      'Southeast': 'assets/images/south_east.png',
      'South-East': 'assets/images/south_east.png',
      'South': 'assets/images/south.png',
      'Southwest': 'assets/images/south_west.png',
      'South-West': 'assets/images/south_west.png',
      'West': 'assets/images/west.png',
      'Northwest': 'assets/images/north_west.png',
      'North-West': 'assets/images/north_west.png',
    };

    // Ensure we always have 8 directions, sorted in standard order
    final standardOrder = ['North', 'Northeast', 'East', 'Southeast', 'South', 'Southwest', 'West', 'Northwest'];
    final sortedDirections = <Map<String, String>>[];
    
    for (var dirName in standardOrder) {
      final found = directions.firstWhere(
        (d) => d['direction']?.toLowerCase() == dirName.toLowerCase() ||
               d['direction']?.toLowerCase() == dirName.replaceAll('-', '').toLowerCase(),
        orElse: () => {'direction': dirName, 'description': 'Analysis pending.'},
      );
      sortedDirections.add(found);
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: sortedDirections.map((dir) {
        final directionName = dir['direction'] ?? '';
        final iconPath = directionIcons[directionName] ?? 'assets/images/north.png';
        return _DirectionCard(
          title: directionName,
          desc: dir['description'] ?? 'Analysis pending.',
          iconPath: iconPath,
        );
      }).toList(),
    );
  }

  Widget roomAnalysisSection(List<Map<String, String>> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.grid_view, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'ROOM ANALYSIS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// LIST
        ...rooms.map((room) => roomAnalysisCard(
          title: room['room'] ?? '',
          subtitle: room['description'] ?? '',
          score: room['score'] ?? '',
        )),
      ],
    );
  }

  Widget roomAnalysisDoshSection(List<String> issues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.grid_view, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'ROOM ANALYSIS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// CARDS
        ...issues.map((issue) {
          // Better title/description splitting
          String title = issue.trim();
          String description = '';
          
          if (title.isEmpty) {
            title = 'Vastu Issue';
            description = 'Analysis finding.';
          } else if (title.contains(':')) {
            final parts = title.split(':');
            title = parts.first.trim();
            description = parts.length > 1 ? parts.skip(1).join(':').trim() : '';
          } else if (title.length > 50) {
            // If no colon, split at first sentence
            final sentenceEnd = title.indexOf('.');
            if (sentenceEnd > 0 && sentenceEnd < 50 && sentenceEnd < title.length) {
              final originalTitle = title;
              title = originalTitle.substring(0, sentenceEnd).trim();
              description = (sentenceEnd + 1 < originalTitle.length) 
                  ? originalTitle.substring(sentenceEnd + 1).trim() 
                  : '';
            } else {
              final maxLen = title.length > 40 ? 40 : title.length;
              if (maxLen > 0 && maxLen <= title.length) {
                final originalTitle = title;
                title = originalTitle.substring(0, maxLen).trim() + (originalTitle.length > 40 ? '...' : '');
                description = originalTitle.length > 40 ? originalTitle : '';
              }
            }
          } else {
            title = title;
            description = '';
          }
          
          return doshInfoCard(
            title: title.isNotEmpty ? title : 'Vastu Issue',
            description: description.isNotEmpty ? description : 'Vastu analysis finding.',
          );
        }),
      ],
    );
  }

  Widget positiveAspectsSection(List<String> aspects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.check_circle_outline,
                size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'POSITIVE ASPECTS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// CARDS
        ...aspects.map((aspect) {
          // Better title/description splitting
          String title = aspect.trim();
          String description = '';
          
          if (title.isEmpty) {
            title = 'Positive Aspect';
            description = 'Positive Vastu aspect.';
          } else if (title.contains(':')) {
            final parts = title.split(':');
            title = parts.first.trim();
            description = parts.length > 1 ? parts.skip(1).join(':').trim() : '';
          } else if (title.length > 50) {
            // If no colon, split at first sentence
            final sentenceEnd = title.indexOf('.');
            if (sentenceEnd > 0 && sentenceEnd < 50 && sentenceEnd < title.length) {
              final originalTitle = title;
              title = originalTitle.substring(0, sentenceEnd).trim();
              description = (sentenceEnd + 1 < originalTitle.length) 
                  ? originalTitle.substring(sentenceEnd + 1).trim() 
                  : '';
            } else {
              final maxLen = title.length > 40 ? 40 : title.length;
              if (maxLen > 0 && maxLen <= title.length) {
                final originalTitle = title;
                title = originalTitle.substring(0, maxLen).trim() + (originalTitle.length > 40 ? '...' : '');
                description = originalTitle.length > 40 ? originalTitle : '';
              }
            }
          } else {
            title = title;
            description = '';
          }
          
          return positiveAspectCard(
            title: title.isNotEmpty ? title : 'Positive Aspect',
            description: description.isNotEmpty ? description : 'Positive Vastu aspect.',
          );
        }),
      ],
    );
  }

  Widget recommendationsSection(List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.lightbulb_outline,
                size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'RECOMMENDATIONS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// CARDS
        ...recommendations.map((rec) {
          // Better title/description splitting
          String title = rec.trim();
          String description = '';
          
          if (title.isEmpty) {
            title = 'Recommendation';
            description = 'Vastu recommendation.';
          } else if (title.contains(':')) {
            final parts = title.split(':');
            title = parts.first.trim();
            description = parts.length > 1 ? parts.skip(1).join(':').trim() : '';
          } else if (title.length > 50) {
            // If no colon, split at first sentence
            final sentenceEnd = title.indexOf('.');
            if (sentenceEnd > 0 && sentenceEnd < 50 && sentenceEnd < title.length) {
              final originalTitle = title;
              title = originalTitle.substring(0, sentenceEnd).trim();
              description = (sentenceEnd + 1 < originalTitle.length) 
                  ? originalTitle.substring(sentenceEnd + 1).trim() 
                  : '';
            } else {
              final maxLen = title.length > 40 ? 40 : title.length;
              if (maxLen > 0 && maxLen <= title.length) {
                final originalTitle = title;
                title = originalTitle.substring(0, maxLen).trim() + (originalTitle.length > 40 ? '...' : '');
                description = originalTitle.length > 40 ? originalTitle : '';
              }
            }
          } else {
            title = title;
            description = '';
          }
          
          return recommendationCard(
            title: title.isNotEmpty ? title : 'Recommendation',
            description: description.isNotEmpty ? description : 'Vastu recommendation.',
          );
        }),
      ],
    );
  }
}

// ================= SUB WIDGETS =================

class _NorthOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NorthOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        side: BorderSide(
          color: isSelected 
              ? AiVaastuAnalysisNewScreen.kGreen 
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isSelected 
            ? AiVaastuAnalysisNewScreen.kGreen.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AiVaastuAnalysisNewScreen.kGreen
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? Colors.black : Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SUB Direction ANALYSIS WIDGETS =================
class _DirectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DirectionTile(
    this.icon,
    this.label, {
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AiVaastuAnalysisNewScreen.kGreen 
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? AiVaastuAnalysisNewScreen.kGreen.withOpacity(0.1)
              : Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AiVaastuAnalysisNewScreen.kGreen
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.black : Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SUB ROOM ANALYSIS WIDGETS =================
Widget roomAnalysisCard({
  required String title,
  required String subtitle,
  required String score,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// LEFT TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        /// RIGHT SCORE
        if (score.isNotEmpty)
          Text(
            score,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2EE59D),
            ),
          ),
      ],
    ),
  );
}

// ================= SUB ROOM ANALYSIS 2 WIDGETS =================

Widget doshInfoCard({
  required String title,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FAFF), // light blue bg
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),

        /// DESCRIPTION
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade700,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

// ================= SUB POSITIVE ASPECTS WIDGETS =================
Widget positiveAspectCard({
  required String title,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FAFF), // light blue bg
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT ICON (GANESH / BADGE)
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/images/positive_aspects _bullets.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),

        /// TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ================= SUB RECOMMENDATIONS  WIDGETS =================

Widget recommendationCard({
  required String title,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FAFF), // light blue bg
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),

        /// DESCRIPTION
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade700,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

class _DirectionCard extends StatelessWidget {
  final String title;
  final String desc;
  final String iconPath;

  const _DirectionCard({
    required this.title,
    required this.desc,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
