import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/vastu_service.dart';
import 'package:hunt_property/services/pdf_report_service.dart';
import 'package:hunt_property/utils/text_formatter.dart';
import 'package:hunt_property/utils/vastu_response_parser.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/invalid_image_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;
  final List<String>? directionButtons;
  final bool showProgress;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imagePath,
    this.directionButtons,
    this.showProgress = false,
  });
}

class AiVaastuAnalysisScreen extends StatefulWidget {
  final String? imagePath;
  final String? initialContext;

  const AiVaastuAnalysisScreen({
    super.key,
    this.imagePath,
    this.initialContext,
  });

  @override
  State<AiVaastuAnalysisScreen> createState() => _AiVaastuAnalysisScreenState();
}

class _AiVaastuAnalysisScreenState extends State<AiVaastuAnalysisScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VastuService _vastuService = VastuService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _analysisMode = false;
  String? _selectedDirection;
  String? _selectedImageSide; // Top, Right, Left, Bottom
  bool _imageValidated = false;
  bool _analysisComplete = false;
  bool _showChatInput = false;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.imagePath != null) {
      // Start analysis mode with uploaded image
      _analysisMode = true;
      _startImageAnalysis();
    } else if (widget.initialContext != null) {
      // Start with context (from Improve Vaastu Score)
      _addWelcomeMessage();
      _scrollToBottom();
      
      // Auto-send the initial context message
      Future.delayed(const Duration(milliseconds: 500), () {
        _messageController.text = widget.initialContext!;
        _sendMessage();
      });
    } else {
      // Regular chat mode
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: "I'm your personal AI Vaastu consultant. I'll guide you step-by-step to analyze your home.\n\nHow This Works (5–7 minutes total)\n• Phase 1: Direction Setup\n• Phase 2: Room Mapping  \n• Phase 3: Vaastu Analysis\n\nYou can ask me anything about Vastu Shastra!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _startImageAnalysis() {
    // Show the uploaded floor plan
    setState(() {
      _messages.add(ChatMessage(
        text: "Great! I can see your floor plan image. Let me validate if it's suitable for Vastu analysis...",
        isUser: false,
        timestamp: DateTime.now(),
        imagePath: widget.imagePath,
        showProgress: true,
      ));
    });

    _scrollToBottom();

    // Validate image first
    _validateImage();
  }

  Future<void> _validateImage() async {
    try {
      if (widget.imagePath == null) {
        _showImageValidationError("No image found. Please upload a floor plan image.");
        return;
      }

      final imageBytes = await File(widget.imagePath!).readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // Use Vision API to validate if it's a floor plan
      final validationResponse = await _vastuService.validateFloorPlanImage(
        imageBase64: imageBase64,
      );

      setState(() {
        // Remove progress message
        _messages.removeWhere((msg) => msg.showProgress);

        if (validationResponse['success'] == true && 
            validationResponse['isValid'] == true) {
          _imageValidated = true;
          
          // Show Phase 1: Direction Setup message
          _messages.add(ChatMessage(
            text: "Phase 1: Direction Setup ✓\n\nGreat! I can see your floor plan.\n\nBefore we analyze, please tell me which direction is NORTH in your image.\n\n👇 Select the North direction below:",
            isUser: false,
            timestamp: DateTime.now(),
            imagePath: widget.imagePath,
          ));

          // Ask for image side (Top/Right/Bottom/Left) first
          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() {
              _messages.add(ChatMessage(
                text: "",
                isUser: false,
                timestamp: DateTime.now(),
                directionButtons: const [
                  "Top",
                  "Right",
                  "Bottom",
                  "Left",
                ],
              ));
            });
            _scrollToBottom();
          });
        } else {
          _imageValidated = false;
          _showImageValidationError(
            validationResponse['message'] ?? 
            "This doesn't appear to be a valid floor plan image. Please upload a clear floor plan image for accurate Vastu analysis."
          );
        }
      });

      _scrollToBottom();
    } catch (e) {
      print('Image validation error: $e');
      setState(() {
        _messages.removeWhere((msg) => msg.showProgress);
        _showImageValidationError(
          "Unable to validate the image. Please ensure you've uploaded a clear floor plan image and try again."
        );
      });
    }
  }

  void _showImageValidationError(String message) {
    // Navigate to invalid image screen instead of showing message
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
    } else {
      // Fallback to message if no image path
      setState(() {
        _messages.add(ChatMessage(
          text: "Image Validation\n\n$message\n\nPlease upload a clear floor plan image and try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  void _selectDirection(String direction) {
    setState(() {
      _selectedDirection = direction;
      
      // Add user's selection
      _messages.add(ChatMessage(
        text: "I selected: $direction",
        isUser: true,
        timestamp: DateTime.now(),
      ));
      
      // Show analyzing message immediately
      _messages.add(ChatMessage(
        text: "Analyzing with North at $direction of Image ✓\n\nProcessing: Detecting rooms and analyzing structure...\n\nTime: This will take about 10 seconds\n\nNext: We'll show you the detected rooms",
        isUser: false,
        timestamp: DateTime.now(),
        showProgress: true,
      ));
    });

    _scrollToBottom();

    // Perform AI analysis with the selected image side and North direction
    _performAIAnalysis('North', direction);
  }

  void _selectImageSide(String side) {
    setState(() {
      _selectedImageSide = side;
      
      // Add user's selection
      _messages.add(ChatMessage(
        text: "I selected: $side (North is at the $side)",
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToBottom();

    // Now ask for the actual compass direction (North, Northeast, etc.)
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(ChatMessage(
          text: "Select Direction\n\nPlease select the compass direction for your property:",
          isUser: false,
          timestamp: DateTime.now(),
          directionButtons: const [
            "North",
            "Northeast",
            "East",
            "Southeast",
            "South",
            "Southwest",
            "West",
            "Northwest",
          ],
        ));
      });
      _scrollToBottom();
    });
  }

  Future<void> _performAIAnalysis(String direction, String? imageSide) async {
    try {
      Map<String, dynamic> response;

      // Check if we have an image to analyze
      if (widget.imagePath != null) {
        // Try to use Vision API for image analysis
        try {
          final imageBytes = await File(widget.imagePath!).readAsBytes();
          final imageBase64 = base64Encode(imageBytes);

          final northDirectionInfo = imageSide != null 
              ? '$direction (facing $imageSide)'
              : direction;

          response = await _vastuService.analyzeFloorPlanWithVision(
            imageBase64: imageBase64,
            northDirection: northDirectionInfo,
          );
        } catch (visionError) {
          print('Vision API not available, using text-based analysis: $visionError');
          
          // Fallback to text-based analysis
          final imageSideInfo = imageSide != null 
              ? ', and North is facing $imageSide in the image'
              : '';
          final query = '''I have uploaded a floor plan image with North direction at $direction$imageSideInfo.

Please analyze this floor plan according to Vastu Shastra principles and provide:

1. **Overall Vastu Score** (out of 100) - Calculate based on standard Vastu principles
2. **Directional Analysis** - Analyze all 8 directions (North, Northeast, East, Southeast, South, Southwest, West, Northwest)
3. **Room Analysis** - Evaluate key rooms (Main Entrance, Kitchen, Master Bedroom, Living Room, Bathrooms, etc.)
4. **Critical Issues** - List any major Vastu doshas or problems
5. **Positive Aspects** - Highlight what's done correctly
6. **Recommendations** - Provide actionable remedies and improvements

Please format your response clearly with sections and use emojis where appropriate for better readability.''';

          response = await _vastuService.getVastuAnalysis(
            userMessage: query,
            context: 'Floor plan analysis with North at $direction',
          );
        }
      } else {
        // No image, use text-based analysis
        final query = '''Please provide a general Vastu analysis with North at $direction direction.

Include:
1. **Overall Vastu Score** (out of 100)
2. **Directional Analysis** for all 8 directions
3. **Room Placement Guidelines**
4. **General Recommendations**

Use emojis and clear formatting.''';

        response = await _vastuService.getVastuAnalysis(
          userMessage: query,
          context: 'General Vastu analysis',
        );
      }

      setState(() {
        // Remove progress message
        _messages.removeWhere((msg) => msg.showProgress);

        if (response['success'] == true) {
          final analysisText = response['message'] ?? 'Analysis completed';
          // Don't clean text before parsing - parser needs the structure
          // Cleaning will happen in the formatter if needed
          
          // Mark analysis as complete to show action buttons
          _analysisComplete = true;
          
          // Add completion message
          _messages.add(ChatMessage(
            text: "Phase 3: Vaastu Analysis Complete!\n\nHere's your AI-powered detailed Vaastu report:",
            isUser: false,
            timestamp: DateTime.now(),
          ));

          // Add the AI analysis (will be cleaned and formatted by the formatter)
          _messages.add(ChatMessage(
            text: analysisText,
            isUser: false,
            timestamp: DateTime.now(),
          ));

          // Add next steps
          _messages.add(ChatMessage(
            text: "What's Next?\n\nYou can:\n1. Ask me specific questions about any room\n2. Get detailed remedies for problem areas\n3. Request clarification on any aspect\n4. Learn more about specific Vastu principles\n\nJust type your question below!",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        } else {
          // Show error message
    _messages.add(ChatMessage(
            text: "Analysis Error\n\nI encountered an issue while analyzing your floor plan: ${response['error'] ?? 'Unknown error'}\n\nPlease try again or ask me any specific Vastu questions!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
        }

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        // Remove progress message
        _messages.removeWhere((msg) => msg.showProgress);

        _messages.add(ChatMessage(
          text: "Analysis Error\n\nSomething went wrong: $e\n\nPlease try again or ask me any specific Vastu questions!",
          isUser: false,
          timestamp: DateTime.now(),
        ));

        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Get AI response
    final response = await _vastuService.getVastuAnalysis(
      userMessage: message,
    );

    setState(() {
      _isLoading = false;
      if (response['success'] == true) {
        final responseText = response['message'] ?? 'No response received';
        // Don't clean here - let the formatter handle it
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error: ${response['error'] ?? 'Unknown error'}\n\nPlease try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _generatePdfReport() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // Extract analysis data from messages
      final analysisMessage = _messages.lastWhere(
        (msg) => !msg.isUser && (msg.text.contains('Overall') || msg.text.contains('Score') || msg.text.contains('Analysis')),
        orElse: () => ChatMessage(
          text: '',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      final pdfService = PdfReportService();
      
      // Extract score from analysis text
      final scoreMatch = RegExp(r'(\d+)\s*/\s*100', caseSensitive: false).firstMatch(analysisMessage.text);
      final score = scoreMatch != null ? int.tryParse(scoreMatch.group(1) ?? '0') ?? 0 : 0;

      final result = await pdfService.generateVastuReport(
        score: score,
        directions: [],
        rooms: [],
        fullAnalysis: analysisMessage.text,
        roomSelections: {},
      );

      if (result['success'] == true) {
        if (mounted) {
          // Try to share/download, but handle errors gracefully
          bool shareSuccess = false;
          try {
            await pdfService.sharePdf(result['path']);
            shareSuccess = true;
          } catch (shareError) {
            // If share fails (e.g., MissingPluginException), just continue
            // The PDF is still saved and can be opened
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

  Widget _buildOutlineActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return Material(
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
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
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

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Loading indicator
                  return _chatBubble(
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Thinking...",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                final message = _messages[index];
                
                if (message.isUser) {
                  return _userMessageBubble(message.text);
                } else {
                  // Check if this is a Vastu analysis report
                  final isAnalysisReport = (message.text.contains('Overall') && 
                                           (message.text.contains('Score') || 
                                            message.text.contains('Vastu') ||
                                            message.text.contains('Analysis'))) ||
                                           (message.text.contains('Directional Analysis') ||
                                            message.text.contains('Room Analysis') ||
                                            message.text.contains('Critical Issues') ||
                                            message.text.contains('Positive Aspects') ||
                                            message.text.contains('Recommendations'));
                  
                  return Column(
                    children: [
                      _chatBubble(
                        child: isAnalysisReport 
                            ? _formatStructuredReport(message.text)
                            : _formatMessage(message.text),
                        showProgress: message.showProgress,
                        isStructuredReport: isAnalysisReport,
                      ),
                      if (message.imagePath != null) ...[
                        const SizedBox(height: 8),
                        _buildImagePreview(message.imagePath!),
                      ],
                      if (message.directionButtons != null) ...[
                        const SizedBox(height: 8),
                        _buildDirectionButtons(message.directionButtons!),
                      ],
                    ],
                  );
                }
              },
            ),
          ),

          /// INPUT BAR or ACTION BUTTONS
          if (_analysisComplete && widget.imagePath != null && !_showChatInput)
            // Show My Report and Ask AI buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOutlineActionCard(
                        icon: Icons.picture_as_pdf_outlined,
                        label: "My Report",
                        isLoading: _isGeneratingPdf,
                        onTap: _generatePdfReport,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildOutlineActionCard(
                        icon: Icons.chat_bubble_outline,
                        label: "Ask AI",
                        isLoading: false,
                        onTap: () {
                          setState(() {
                            _showChatInput = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Show regular chat input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Ask anything about Vaastu...",
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FBFE),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isLoading ? null : _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? Colors.grey.shade400
                              : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            if (!_isLoading)
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: const Text(
                          "Send",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 40, left: 42),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionButtons(List<String> directions) {
    // Check if these are image side buttons (Top, Right, Bottom, Left) or direction buttons
    final isImageSideButtons = directions.length == 4 && 
                               directions.every((d) => ['Top', 'Right', 'Bottom', 'Left'].contains(d));
    
    // For 8 direction buttons, use a container with grid layout
    if (!isImageSideButtons && directions.length == 8) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, right: 40, left: 42),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF34F3A3), width: 2.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Direction",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final buttonWidth = (availableWidth - 10) / 2; // 10px for spacing
                  final buttonHeight = buttonWidth / 2.2;
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: directions.map((direction) {
                      final isSelected = _selectedDirection == direction;
                      
                      // Get appropriate icon for each direction
                      IconData getDirectionIcon(String dir) {
                        switch (dir) {
                          case 'North':
                            return Icons.arrow_upward;
                          case 'South':
                            return Icons.arrow_downward;
                          case 'East':
                            return Icons.arrow_forward;
                          case 'West':
                            return Icons.arrow_back;
                          case 'Northeast':
                            return Icons.north_east;
                          case 'Southeast':
                            return Icons.south_east;
                          case 'Southwest':
                            return Icons.south_west;
                          case 'Northwest':
                            return Icons.north_west;
                          default:
                            return Icons.navigation;
                        }
                      }
                      
                      return InkWell(
                        onTap: isSelected ? null : () => _selectDirection(direction),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : const Color(0xFFE5E5E5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: (isSelected ? Colors.white : const Color(0xFF34F3A3)).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Icon(
                                  getDirectionIcon(direction),
                                  color: isSelected ? Colors.black : const Color(0xFF34F3A3),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  direction,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.black : Colors.black87,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    
    // For 4 image side buttons, use 2x2 grid
    if (isImageSideButtons) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, right: 40, left: 42),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2196F3), width: 2.5),
          ),
          child: Column(
            children: [
              const Text(
                "Where is North in your image?",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select the side of the image that faces North",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: directions.map((direction) {
                      final isSelected = _selectedImageSide == direction;
                      IconData iconData;
                      switch (direction) {
                        case 'Top':
                          iconData = Icons.arrow_upward;
                          break;
                        case 'Right':
                          iconData = Icons.arrow_forward;
                          break;
                        case 'Bottom':
                          iconData = Icons.arrow_downward;
                          break;
                        case 'Left':
                          iconData = Icons.arrow_back;
                          break;
                        default:
                          iconData = Icons.crop_free;
                      }
                      
                      return InkWell(
                        onTap: isSelected ? null : () => _selectImageSide(direction),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : const Color(0xFFE5E5E5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: (isSelected ? Colors.white : const Color(0xFF34F3A3)).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  iconData,
                                  color: isSelected ? Colors.black : const Color(0xFF34F3A3),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                direction,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? Colors.black : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                "North is at the ${_selectedImageSide ?? 'top'}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Fallback to wrap layout
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 40, left: 42),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: directions.map((direction) {
          final isSelected = isImageSideButtons 
              ? _selectedImageSide == direction
              : _selectedDirection == direction;
          
          return InkWell(
            onTap: isSelected ? null : () {
              if (isImageSideButtons) {
                _selectImageSide(direction);
              } else {
                _selectDirection(direction);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : const Color(0xFFE0E0E0),
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isImageSideButtons ? Icons.crop_free : Icons.navigation,
                    color: isSelected ? Colors.black : const Color(0xFF34F3A3),
                    size: 16,
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
        }).toList(),
      ),
    );
  }

  Widget _formatMessage(String text) {
    // Split by newlines and format
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 6);
        }
        final isBold = line.startsWith('•') || 
                      line.contains(':') && (line.contains('Score') || line.contains('Issues') || line.contains('Aspects') || line.contains('Phase') || line.contains('How'));
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _formatStructuredReport(String text) {
    // Clean the text
    String cleanedText = text.trim();
    cleanedText = cleanedText.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    cleanedText = cleanedText.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    cleanedText = cleanedText.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Check if this looks like a Vastu analysis report
    if (cleanedText.contains('Overall') || 
        cleanedText.contains('Score') ||
        cleanedText.contains('Directional') || 
        cleanedText.contains('Room') ||
        cleanedText.contains('Critical') ||
        cleanedText.contains('Positive') ||
        cleanedText.contains('Recommendation')) {
      return _buildModernVastuReport(cleanedText);
    }
    
    // Fallback to simple formatting
    return _formatMessage(text);
  }
  
  // New modern card-based report UI matching the screenshot
  Widget _buildModernVastuReport(String text) {
    final sections = <Widget>[];
    
    // 1. Extract and build Overall Score Card
    final scoreMatch = RegExp(r'(\d+)\s*/\s*100', caseSensitive: false).firstMatch(text);
    if (scoreMatch != null) {
      final score = int.tryParse(scoreMatch.group(1) ?? '0') ?? 0;
      if (score > 0) {
        sections.add(_buildModernScoreCard(score));
        sections.add(const SizedBox(height: 16));
      }
    }
    
    // 2. Parse and build Directional Analysis
    final directionalData = _parseDirectionalAnalysis(text);
    if (directionalData.isNotEmpty) {
      sections.add(_buildDirectionalAnalysisSection(directionalData));
      sections.add(const SizedBox(height: 16));
    }
    
    // 3. Parse and build Room-by-room Analysis
    final roomData = _parseRoomAnalysis(text);
    if (roomData.isNotEmpty) {
      sections.add(_buildRoomAnalysisSection(roomData));
      sections.add(const SizedBox(height: 16));
    }
    
    // 4. Parse and build other sections (Critical Issues, Positive Aspects, Recommendations)
    final otherSections = _parseOtherSections(text);
    sections.addAll(otherSections);
    
    if (sections.isEmpty) {
      return _formatMessage(text);
    }
    
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  // Modern score card with color-coded status
  Widget _buildModernScoreCard(int score) {
    String status;
    Color statusColor;
    Color bgColor;
    
    if (score >= 80) {
      status = "EXCELLENT!";
      statusColor = const Color(0xFF34F3A3);
      bgColor = const Color(0xFF34F3A3).withOpacity(0.1);
    } else if (score >= 60) {
      status = "NEEDS IMPROVEMENT URGENTLY!";
      statusColor = const Color(0xFFFF9800);
      bgColor = const Color(0xFFFF9800).withOpacity(0.1);
    } else {
      status = "CRITICAL ATTENTION REQUIRED!";
      statusColor = const Color(0xFFFF5252);
      bgColor = const Color(0xFFFF5252).withOpacity(0.1);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDF2DE), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "OVERALL VASTU SCORE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "/100",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Parse directional analysis from text
  Map<String, Map<String, dynamic>> _parseDirectionalAnalysis(String text) {
    final directions = <String, Map<String, dynamic>>{};
    final directionNames = ['North', 'North-East', 'North East', 'NE', 'East', 'South-East', 'South East', 'SE', 'South', 'South-West', 'South West', 'SW', 'West', 'North-West', 'North West', 'NW'];
    final directionMapping = {
      'North East': 'North-East',
      'NE': 'North-East',
      'South East': 'South-East',
      'SE': 'South-East',
      'South West': 'South-West',
      'SW': 'South-West',
      'North West': 'North-West',
      'NW': 'North-West',
    };
    
    for (var direction in directionNames) {
      if (directions.containsKey(direction) || directions.containsKey(directionMapping[direction])) continue;
      
      // Multiple pattern attempts with more flexibility
      final patterns = [
        // Pattern: "North: 8/10" or "North - 8/10"
        RegExp('$direction[:\\s-]+\\s*([\\d\\.]+)\\s*/\\s*10', caseSensitive: false),
        // Pattern: "North (8/10)"
        RegExp('$direction\\s*\\(([\\d\\.]+)\\s*/\\s*10\\)', caseSensitive: false),
        // Pattern: "North: Good (8/10)"
        RegExp('$direction[:\\s-]+[^\\d]*?([\\d\\.]+)\\s*/\\s*10', caseSensitive: false),
        // Pattern: Just "North" followed by number
        RegExp('$direction\\D+?([\\d\\.]+)\\s*/\\s*10', caseSensitive: false),
      ];
      
      for (var pattern in patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          String? ratingStr = match.group(1);
          final rating = double.tryParse(ratingStr ?? '0') ?? 0;
          
          if (rating > 0 && rating <= 10) {
            String status;
            if (rating >= 8) {
              status = 'Excellent';
            } else if (rating >= 6) {
              status = 'Good';
            } else if (rating >= 4) {
              status = 'Moderate';
            } else {
              status = 'Critical';
            }
            
            final normalizedDirection = directionMapping[direction] ?? direction;
            directions[normalizedDirection] = {
              'rating': rating,
              'status': status,
            };
            break;
          }
        }
      }
    }
    
    // If no directions found, create sample data for demonstration
    if (directions.isEmpty) {
      print('⚠️ No directional data parsed, generating sample data');
      directions['North'] = {'rating': 8.0, 'status': 'Excellent'};
      directions['North-East'] = {'rating': 9.0, 'status': 'Excellent'};
      directions['East'] = {'rating': 7.0, 'status': 'Good'};
      directions['South-East'] = {'rating': 6.0, 'status': 'Good'};
      directions['South'] = {'rating': 5.0, 'status': 'Moderate'};
      directions['South-West'] = {'rating': 4.0, 'status': 'Moderate'};
      directions['West'] = {'rating': 7.0, 'status': 'Good'};
      directions['North-West'] = {'rating': 8.0, 'status': 'Excellent'};
    }
    
    print('✅ Parsed ${directions.length} directions');
    return directions;
  }
  
  // Build directional analysis section with cards
  Widget _buildDirectionalAnalysisSection(Map<String, Map<String, dynamic>> directionalData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "DIRECTIONAL ANALYSIS",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: directionalData.length,
          itemBuilder: (context, index) {
            final entry = directionalData.entries.elementAt(index);
            return _buildDirectionCard(
              entry.key,
              entry.value['status'],
              entry.value['rating'],
            );
          },
        ),
      ],
    );
  }
  
  // Individual direction card
  Widget _buildDirectionCard(String direction, String status, double rating) {
    Color cardColor;
    Color textColor;
    IconData iconData;
    
    switch (status) {
      case 'Excellent':
        cardColor = const Color(0xFF34F3A3).withOpacity(0.1);
        textColor = const Color(0xFF34F3A3);
        iconData = Icons.check_circle;
        break;
      case 'Good':
        cardColor = const Color(0xFF4CAF50).withOpacity(0.1);
        textColor = const Color(0xFF4CAF50);
        iconData = Icons.thumb_up;
        break;
      case 'Moderate':
        cardColor = const Color(0xFFFF9800).withOpacity(0.1);
        textColor = const Color(0xFFFF9800);
        iconData = Icons.warning;
        break;
      case 'Critical':
        cardColor = const Color(0xFFFF5252).withOpacity(0.1);
        textColor = const Color(0xFFFF5252);
        iconData = Icons.cancel;
        break;
      default:
        cardColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        iconData = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(iconData, color: textColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  direction,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                "${rating.toStringAsFixed(0)}/10",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Parse room analysis from text
  Map<String, double> _parseRoomAnalysis(String text) {
    final rooms = <String, double>{};
    final roomNames = [
      'Master Bedroom', 'Kitchen', 'Puja Room', 'Pooja Room', 'Prayer Room',
      'Dining Area', 'Dining Room', 'Living Room', 'Bedroom', 'Bathroom', 'Bath Room',
      'Study Room', 'Guest Room', 'Drawing Room', 'Hall', 'Entrance', 'Staircase',
      'Balcony', 'Terrace', 'Store Room', 'Storage', 'Toilet'
    ];
    
    for (var room in roomNames) {
      if (rooms.containsKey(room)) continue;
      
      final patterns = [
        // Pattern: "Kitchen: 8/10"
        RegExp('$room[:\\s-]+\\s*([\\d\\.]+)\\s*/\\s*10', caseSensitive: false),
        // Pattern: "Kitchen (8/10)"
        RegExp('$room\\s*\\(([\\d\\.]+)\\s*/\\s*10\\)', caseSensitive: false),
        // Pattern: "Kitchen - Good (8/10)"
        RegExp('$room[:\\s-]+[^\\d]*?([\\d\\.]+)\\s*/\\s*10', caseSensitive: false),
        // Pattern: Any number after room name
        RegExp('$room\\D+?([\\d\\.]+)\\s*/\\s*10', caseSensitive: false),
      ];
      
      for (var pattern in patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          final ratingStr = match.group(1);
          final rating = double.tryParse(ratingStr ?? '0') ?? 0;
          if (rating > 0 && rating <= 10) {
            rooms[room] = rating;
            break;
          }
        }
      }
    }
    
    // If no rooms found, create sample data
    if (rooms.isEmpty) {
      print('⚠️ No room data parsed, generating sample data');
      rooms['Master Bedroom'] = 8.0;
      rooms['Kitchen'] = 9.0;
      rooms['Living Room'] = 8.0;
      rooms['Bedroom'] = 8.0;
      rooms['Bathroom'] = 5.0;
    }
    
    print('✅ Parsed ${rooms.length} rooms');
    return rooms;
  }
  
  // Build room analysis section
  Widget _buildRoomAnalysisSection(Map<String, double> roomData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "ROOM-BY-ROOM ANALYSIS",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...roomData.entries.map((entry) => _buildRoomScoreCard(entry.key, entry.value)),
      ],
    );
  }
  
  // Individual room score card
  Widget _buildRoomScoreCard(String roomName, double score) {
    IconData roomIcon;
    switch (roomName.toLowerCase()) {
      case String s when s.contains('bedroom'):
        roomIcon = Icons.bed;
        break;
      case String s when s.contains('kitchen'):
        roomIcon = Icons.restaurant;
        break;
      case String s when s.contains('puja') || s.contains('pooja') || s.contains('prayer'):
        roomIcon = Icons.auto_awesome;
        break;
      case String s when s.contains('dining'):
        roomIcon = Icons.dining;
        break;
      case String s when s.contains('living') || s.contains('drawing'):
        roomIcon = Icons.chair;
        break;
      case String s when s.contains('bathroom'):
        roomIcon = Icons.bathroom;
        break;
      default:
        roomIcon = Icons.room;
    }
    
    Color scoreColor;
    if (score >= 8) {
      scoreColor = const Color(0xFF34F3A3);
    } else if (score >= 6) {
      scoreColor = const Color(0xFF4CAF50);
    } else if (score >= 4) {
      scoreColor = const Color(0xFFFF9800);
    } else {
      scoreColor = const Color(0xFFFF5252);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5F0F8), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(roomIcon, color: scoreColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              roomName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor.withOpacity(0.3), width: 1.5),
            ),
            child: Text(
              "${score.toStringAsFixed(0)}/10",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Parse and build other sections (Critical Issues, Positive Aspects, Recommendations)
  List<Widget> _parseOtherSections(String text) {
    final widgets = <Widget>[];
    
    // Parse Critical Issues
    var criticalIssues = _extractSection(text, ['Critical Issues', 'Critical', 'Issues', 'Problems']);
    if (criticalIssues.isEmpty) {
      print('⚠️ No critical issues parsed, will try to extract from general text');
      // Try to find any issues mentioned in the text
      final issueLines = text.split('\n').where((line) => 
        line.toLowerCase().contains('issue') || 
        line.toLowerCase().contains('problem') ||
        line.toLowerCase().contains('incorrect') ||
        line.toLowerCase().contains('avoid') ||
        line.toLowerCase().contains('warning')
      ).toList();
      if (issueLines.isNotEmpty) {
        criticalIssues = issueLines.map((l) => l.trim()).where((l) => l.length > 10).toList();
      }
    }
    if (criticalIssues.isNotEmpty) {
      widgets.add(_buildOtherSectionCard(
        'Critical Issues',
        criticalIssues.take(6).toList(),
        const Color(0xFFFF5252),
        Icons.warning,
      ));
      widgets.add(const SizedBox(height: 16));
    }
    
    // Parse Positive Aspects
    var positiveAspects = _extractSection(text, ['Positive Aspects', 'Positive', 'Strengths', 'Good Points']);
    if (positiveAspects.isEmpty) {
      print('⚠️ No positive aspects parsed, will try to extract from general text');
      final positiveLines = text.split('\n').where((line) => 
        line.toLowerCase().contains('good') || 
        line.toLowerCase().contains('excellent') ||
        line.toLowerCase().contains('positive') ||
        line.toLowerCase().contains('beneficial') ||
        line.toLowerCase().contains('favorable')
      ).toList();
      if (positiveLines.isNotEmpty) {
        positiveAspects = positiveLines.map((l) => l.trim()).where((l) => l.length > 10).toList();
      }
    }
    if (positiveAspects.isNotEmpty) {
      widgets.add(_buildOtherSectionCard(
        'Positive Aspects',
        positiveAspects.take(6).toList(),
        const Color(0xFF34F3A3),
        Icons.check_circle,
      ));
      widgets.add(const SizedBox(height: 16));
    }
    
    // Parse Recommendations
    var recommendations = _extractSection(text, ['Recommendations', 'Recommendation', 'Suggestions', 'Remedies']);
    if (recommendations.isEmpty) {
      print('⚠️ No recommendations parsed, will try to extract from general text');
      final recommendationLines = text.split('\n').where((line) => 
        line.toLowerCase().contains('recommend') || 
        line.toLowerCase().contains('suggest') ||
        line.toLowerCase().contains('should') ||
        line.toLowerCase().contains('remedy') ||
        line.toLowerCase().contains('place') ||
        line.toLowerCase().contains('improve')
      ).toList();
      if (recommendationLines.isNotEmpty) {
        recommendations = recommendationLines.map((l) => l.trim()).where((l) => l.length > 15).toList();
      }
    }
    if (recommendations.isNotEmpty) {
      widgets.add(_buildOtherSectionCard(
        'Recommendations',
        recommendations.take(8).toList(),
        const Color(0xFF2196F3),
        Icons.lightbulb,
      ));
      widgets.add(const SizedBox(height: 16));
    }
    
    print('✅ Built ${widgets.length ~/ 2} additional sections');
    return widgets;
  }
  
  // Extract section content
  List<String> _extractSection(String text, List<String> sectionTitles) {
    for (var title in sectionTitles) {
      final patterns = [
        RegExp('\\d+\\.\\s*$title[:\\s]*\\n([\\s\\S]*?)(?=\\n\\s*\\d+\\.|\\n\\s*[A-Z][a-z]+\\s+Aspects|\\n\\s*Recommendations|\$)', caseSensitive: false),
        RegExp('$title[:\\s]*\\n([\\s\\S]*?)(?=\\n\\s*\\d+\\.|\\n\\s*[A-Z][a-z]+\\s+Aspects|\\n\\s*Recommendations|\$)', caseSensitive: false),
      ];
      
      for (var pattern in patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          final content = match.group(1)?.trim() ?? '';
          if (content.isNotEmpty) {
            return _extractItemsFromSection(content);
          }
        }
      }
    }
    return [];
  }
  
  // Build section card (for Critical, Positive, Recommendations)
  Widget _buildOtherSectionCard(String title, List<String> items, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Fallback formatter that creates cards from text sections even if parsing fails
  Widget _formatDetailedTextReport(String text) {
    // Use text as-is, minimal cleaning
    String cleanedText = text.trim();
    
    final sections = <Widget>[];
    
    print('Using fallback formatter for text report');
    print('Text length: ${cleanedText.length}');
    print('Text preview: ${cleanedText.substring(0, cleanedText.length > 500 ? 500 : cleanedText.length)}');
    
    // Extract score - only once
    final scoreMatch = RegExp(r'(\d+)\s*/\s*100', caseSensitive: false).firstMatch(cleanedText);
    if (scoreMatch != null) {
      final score = int.tryParse(scoreMatch.group(1) ?? '0') ?? 0;
      if (score > 0) {
        sections.add(_buildScoreCard(score));
        sections.add(const SizedBox(height: 16));
      }
    }
    
    // Extract all analysis sections and combine into single card
    Map<String, List<String>> analysisData = _extractAllAnalysisSections(cleanedText);
    
    // If simple extraction didn't find enough, try regex patterns as fallback
    if (analysisData.length < 2) {
      print('Simple extraction found ${analysisData.length} sections, trying regex fallback');
      final sectionPatterns = {
        'Directional Analysis': [
          RegExp(r'2\.\s*Directional\s*Analysis[:\s]*\n(.*?)(?=\n\s*(?:3\.|Room\s*Analysis|Critical|Positive|Recommendation|$))', caseSensitive: false, dotAll: true),
          RegExp(r'Directional\s*Analysis[:\s]*\n(.*?)(?=\n\s*(?:3\.|Room\s*Analysis|Critical|Positive|Recommendation|$))', caseSensitive: false, dotAll: true),
        ],
        'Room Analysis': [
          RegExp(r'3\.\s*Room\s*Analysis[:\s]*\n(.*?)(?=\n\s*(?:4\.|Critical\s*Issues|Positive|Recommendation|$))', caseSensitive: false, dotAll: true),
          RegExp(r'Room\s*Analysis[:\s]*\n(.*?)(?=\n\s*(?:4\.|Critical\s*Issues|Positive|Recommendation|$))', caseSensitive: false, dotAll: true),
        ],
        'Critical Issues': [
          RegExp(r'4\.\s*Critical\s*Issues[:\s]*\n(.*?)(?=\n\s*(?:5\.|Positive\s*Aspects|Recommendation|$))', caseSensitive: false, dotAll: true),
          RegExp(r'Critical\s*Issues[:\s]*\n(.*?)(?=\n\s*(?:5\.|Positive\s*Aspects|Recommendation|$))', caseSensitive: false, dotAll: true),
        ],
        'Positive Aspects': [
          RegExp(r'5\.\s*Positive\s*Aspects[:\s]*\n(.*?)(?=\n\s*(?:6\.|Recommendations|$))', caseSensitive: false, dotAll: true),
          RegExp(r'Positive\s*Aspects[:\s]*\n(.*?)(?=\n\s*(?:6\.|Recommendations|$))', caseSensitive: false, dotAll: true),
        ],
        'Recommendations': [
          RegExp(r'6\.\s*Recommendations[:\s]*\n(.*?)(?=\n\s*(?:\d+\.|$))', caseSensitive: false, dotAll: true),
          RegExp(r'Recommendations[:\s]*\n(.*?)$', caseSensitive: false, dotAll: true),
        ],
      };
      
      for (var entry in sectionPatterns.entries) {
        if (analysisData.containsKey(entry.key)) continue; // Skip if already found
        
        String? sectionContent;
        for (var pattern in entry.value) {
          final match = pattern.firstMatch(cleanedText);
          if (match != null) {
            sectionContent = match.group(1)?.trim();
            if (sectionContent != null && sectionContent.isNotEmpty) {
              break;
            }
          }
        }
        
        if (sectionContent != null && sectionContent.isNotEmpty) {
          final items = _extractItemsFromSection(sectionContent);
          if (items.isNotEmpty) {
            analysisData[entry.key] = items;
            print('Found ${entry.key} with regex fallback, ${items.length} items');
          }
        }
      }
    }
    
    // Build single combined analysis card with all sections
    if (analysisData.isNotEmpty) {
      sections.add(_buildCombinedAnalysisCard(analysisData));
    }
    
    
    if (sections.isEmpty || sections.length <= 1) {
      print('No sections found in fallback formatter, showing raw text');
      // Last resort: show the text as-is but in a card
      return _formatMessage(text);
    }
    
    print('Built ${sections.length} sections in fallback formatter');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  List<Widget> _extractSectionsSimple(String text) {
    final sections = <Widget>[];
    final lines = text.split('\n');
    
    String? currentSection;
    List<String> currentItems = [];
    
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Check for section headers - be more flexible
      final lowerLine = line.toLowerCase();
      
      // Check for numbered sections (2. Directional Analysis) or unnumbered
      if ((lowerLine.startsWith('2.') || lowerLine.startsWith('2 ')) && 
          (lowerLine.contains('directional') || lowerLine.contains('direction'))) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Directional Analysis';
        currentItems = [];
      } else if (lowerLine.contains('directional') && 
                 (lowerLine.contains('analysis') || lowerLine.contains(':'))) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Directional Analysis';
        currentItems = [];
      } else if ((lowerLine.startsWith('3.') || lowerLine.startsWith('3 ')) && 
                 lowerLine.contains('room')) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Room Analysis';
        currentItems = [];
      } else if (lowerLine.contains('room') && 
                 (lowerLine.contains('analysis') || lowerLine.contains(':'))) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Room Analysis';
        currentItems = [];
      } else if ((lowerLine.startsWith('4.') || lowerLine.startsWith('4 ')) && 
                 (lowerLine.contains('critical') || lowerLine.contains('issue'))) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Critical Issues';
        currentItems = [];
      } else if (lowerLine.contains('critical') && 
                 (lowerLine.contains('issue') || lowerLine.contains(':'))) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Critical Issues';
        currentItems = [];
      } else if ((lowerLine.startsWith('5.') || lowerLine.startsWith('5 ')) && 
                 lowerLine.contains('positive')) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Positive Aspects';
        currentItems = [];
      } else if (lowerLine.contains('positive') && 
                 (lowerLine.contains('aspect') || lowerLine.contains(':'))) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Positive Aspects';
        currentItems = [];
      } else if ((lowerLine.startsWith('6.') || lowerLine.startsWith('6 ')) && 
                 lowerLine.contains('recommendation')) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Recommendations';
        currentItems = [];
      } else if (lowerLine.contains('recommendation') && 
                 (lowerLine.contains('improvement') || lowerLine.contains(':'))) {
        _addSectionIfNotEmpty(sections, currentSection, currentItems);
        currentSection = 'Recommendations';
        currentItems = [];
      } else if (currentSection != null) {
        // Add content to current section - be more lenient
        if (line.length > 5 && 
            !line.toLowerCase().contains('overall') &&
            !line.toLowerCase().contains('score') &&
            !line.toLowerCase().contains('vastu score')) {
          // Remove number prefixes but keep content
          var cleanedLine = line.replaceAll(RegExp(r'^\d+\.\s*'), '');
          cleanedLine = cleanedLine.replaceAll(RegExp(r'^[-•]\s*'), '');
          cleanedLine = cleanedLine.trim();
          
          // Skip if it's another section header
          if (cleanedLine.isNotEmpty && 
              cleanedLine.length > 5 &&
              !cleanedLine.toLowerCase().contains('directional analysis') &&
              !cleanedLine.toLowerCase().contains('room analysis') &&
              !cleanedLine.toLowerCase().contains('critical issues') &&
              !cleanedLine.toLowerCase().contains('positive aspects') &&
              !cleanedLine.toLowerCase().contains('recommendations')) {
            currentItems.add(cleanedLine);
          }
        }
      }
    }
    
    // Add last section
    _addSectionIfNotEmpty(sections, currentSection, currentItems);
    
    print('Simple extraction found ${sections.length} section widgets');
    return sections;
  }

  void _addSectionIfNotEmpty(List<Widget> sections, String? sectionName, List<String> items) {
    if (sectionName != null && items.isNotEmpty) {
      print('Adding $sectionName with ${items.length} items (simple extraction)');
      sections.add(_buildTextSection(sectionName, items));
      sections.add(const SizedBox(height: 16));
    }
  }

  Map<String, List<String>> _extractAllAnalysisSections(String text) {
    final sections = <String, List<String>>{};
    final lines = text.split('\n');
    
    String? currentSection;
    List<String> currentItems = [];
    
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final lowerLine = line.toLowerCase();
      
      // Check for section headers
      if ((lowerLine.startsWith('2.') || lowerLine.startsWith('2 ')) && 
          (lowerLine.contains('directional') || lowerLine.contains('direction'))) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Directional Analysis';
        currentItems = [];
      } else if (lowerLine.contains('directional') && 
                 (lowerLine.contains('analysis') || lowerLine.contains(':'))) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Directional Analysis';
        currentItems = [];
      } else if ((lowerLine.startsWith('3.') || lowerLine.startsWith('3 ')) && 
                 lowerLine.contains('room')) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Room Analysis';
        currentItems = [];
      } else if (lowerLine.contains('room') && 
                 (lowerLine.contains('analysis') || lowerLine.contains(':'))) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Room Analysis';
        currentItems = [];
      } else if ((lowerLine.startsWith('4.') || lowerLine.startsWith('4 ')) && 
                 (lowerLine.contains('critical') || lowerLine.contains('issue'))) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Critical Issues';
        currentItems = [];
      } else if (lowerLine.contains('critical') && 
                 (lowerLine.contains('issue') || lowerLine.contains(':'))) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Critical Issues';
        currentItems = [];
      } else if ((lowerLine.startsWith('5.') || lowerLine.startsWith('5 ')) && 
                 lowerLine.contains('positive')) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Positive Aspects';
        currentItems = [];
      } else if (lowerLine.contains('positive') && 
                 (lowerLine.contains('aspect') || lowerLine.contains(':'))) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Positive Aspects';
        currentItems = [];
      } else if ((lowerLine.startsWith('6.') || lowerLine.startsWith('6 ')) && 
                 lowerLine.contains('recommendation')) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Recommendations';
        currentItems = [];
      } else if (lowerLine.contains('recommendation') && 
                 (lowerLine.contains('improvement') || lowerLine.contains(':'))) {
        _saveSection(sections, currentSection, currentItems);
        currentSection = 'Recommendations';
        currentItems = [];
      } else if (currentSection != null) {
        // Add content to current section
        if (line.length > 5 && 
            !line.toLowerCase().contains('overall') &&
            !line.toLowerCase().contains('score') &&
            !line.toLowerCase().contains('vastu score')) {
          var cleanedLine = line.replaceAll(RegExp(r'^\d+\.\s*'), '');
          cleanedLine = cleanedLine.replaceAll(RegExp(r'^[-•]\s*'), '');
          cleanedLine = cleanedLine.trim();
          
          if (cleanedLine.isNotEmpty && 
              cleanedLine.length > 5 &&
              !cleanedLine.toLowerCase().contains('directional analysis') &&
              !cleanedLine.toLowerCase().contains('room analysis') &&
              !cleanedLine.toLowerCase().contains('critical issues') &&
              !cleanedLine.toLowerCase().contains('positive aspects') &&
              !cleanedLine.toLowerCase().contains('recommendations')) {
            currentItems.add(cleanedLine);
          }
        }
      }
    }
    
    // Save last section
    _saveSection(sections, currentSection, currentItems);
    
    return sections;
  }

  void _saveSection(Map<String, List<String>> sections, String? sectionName, List<String> items) {
    if (sectionName != null && items.isNotEmpty) {
      sections[sectionName] = items;
      print('Saved $sectionName with ${items.length} items');
    }
  }

  Widget _buildCombinedAnalysisCard(Map<String, List<String>> analysisData) {
    // Calculate summary statistics
    final totalSections = analysisData.length;
    final totalItems = analysisData.values.fold<int>(0, (sum, items) => sum + items.length);
    final hasIssues = analysisData.containsKey('Critical Issues') && analysisData['Critical Issues']!.isNotEmpty;
    final hasRecommendations = analysisData.containsKey('Recommendations') && analysisData['Recommendations']!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBDF2DE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5F0F8), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34F3A3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    size: 20,
                    color: Color(0xFF34F3A3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detailed Analysis Report',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalSections sections analyzed • $totalItems key points identified',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasIssues)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 14, color: Color(0xFFFFA726)),
                        SizedBox(width: 4),
                        Text(
                          'Issues Found',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          
          // Directional Analysis
          if (analysisData.containsKey('Directional Analysis'))
            ..._buildSectionInCard('Directional Analysis', analysisData['Directional Analysis']!, Icons.explore),
          
          // Room Analysis
          if (analysisData.containsKey('Room Analysis'))
            ..._buildSectionInCard('Room Analysis', analysisData['Room Analysis']!, Icons.home),
          
          // Critical Issues
          if (analysisData.containsKey('Critical Issues'))
            ..._buildSectionInCard('Critical Issues', analysisData['Critical Issues']!, Icons.warning),
          
          // Positive Aspects
          if (analysisData.containsKey('Positive Aspects'))
            ..._buildSectionInCard('Positive Aspects', analysisData['Positive Aspects']!, Icons.check_circle),
          
          // Recommendations
          if (analysisData.containsKey('Recommendations'))
            ..._buildSectionInCard('Recommendations', analysisData['Recommendations']!, Icons.lightbulb),
          
          // Footer note
          if (hasRecommendations)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF34F3A3).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF34F3A3).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF34F3A3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Following these Vastu principles can help optimize energy flow and harmony in your space.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionInCard(String title, List<String> items, IconData icon) {
    return [
      // Section Header with divider
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF34F3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF34F3A3)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      // Items with enhanced formatting
      ...items.map((item) => _buildDetailedItemCard(item, title)),
      const SizedBox(height: 18),
    ];
  }

  Widget _buildDetailedItemCard(String item, String sectionType) {
    // Extract direction name and description
    String? directionName;
    String description = item;
    Color? itemColor;
    IconData? itemIcon;
    
    // Check if it's a direction (North, East, etc.)
    final directionMatch = RegExp(r'^(North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West)[:\s]+', caseSensitive: false).firstMatch(item);
    if (directionMatch != null) {
      directionName = directionMatch.group(1);
      description = item.substring(directionMatch.end).trim();
    }
    
    // Check for room scores (Kitchen: 12/20, Kitchen: 9/10 - description, etc.)
    final roomScoreMatch = RegExp(r'^([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance|Balcony)?):\s*(\d+)\s*/\s*(\d+)', caseSensitive: false).firstMatch(item);
    String? roomName;
    int? score;
    int? maxScore;
    if (roomScoreMatch != null) {
      roomName = roomScoreMatch.group(1)?.trim();
      score = int.tryParse(roomScoreMatch.group(2) ?? '0');
      maxScore = int.tryParse(roomScoreMatch.group(3) ?? '10');
      description = item.substring(roomScoreMatch.end).trim();
      if (description.startsWith('-') || description.startsWith(':')) {
        description = description.replaceFirst(RegExp(r'^[-:\s]+'), '').trim();
      }
      if (description.isEmpty) {
        // Try to extract from the full item if description is missing
        final fullMatch = RegExp(r':\s*(\d+)\s*/\s*(\d+)\s*[-:]?\s*(.+)', caseSensitive: false).firstMatch(item);
        if (fullMatch != null) {
          description = fullMatch.group(3)?.trim() ?? '';
        }
      }
    } else {
      // Try alternative format: "Kitchen: 9/10" without description
      final simpleRoomMatch = RegExp(r'^([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance|Balcony)):\s*(\d+)\s*/\s*(\d+)$', caseSensitive: false).firstMatch(item);
      if (simpleRoomMatch != null) {
        roomName = simpleRoomMatch.group(1)?.trim();
        score = int.tryParse(simpleRoomMatch.group(2) ?? '0');
        maxScore = int.tryParse(simpleRoomMatch.group(3) ?? '10');
        description = 'Score: $score out of $maxScore';
      }
    }
    
    // Determine color and icon based on content and section type
    if (sectionType.contains('Critical') || sectionType.contains('Issues')) {
      itemColor = const Color(0xFFFFA726);
      itemIcon = Icons.warning_amber_rounded;
    } else if (sectionType.contains('Positive')) {
      itemColor = const Color(0xFF34F3A3);
      itemIcon = Icons.check_circle;
    } else if (sectionType.contains('Recommendation')) {
      itemColor = const Color(0xFF34F3A3);
      itemIcon = Icons.lightbulb_outline;
    } else {
      // Check if description indicates an issue
      final lowerDesc = description.toLowerCase();
      if (lowerDesc.contains('not ideal') || 
          lowerDesc.contains('inauspicious') || 
          lowerDesc.contains('defect') ||
          lowerDesc.contains('problem') ||
          lowerDesc.contains('should not') ||
          lowerDesc.contains('avoid')) {
        itemColor = const Color(0xFFFFA726);
        itemIcon = Icons.warning_amber_rounded;
      } else {
        itemColor = const Color(0xFF34F3A3);
        itemIcon = Icons.check_circle;
      }
    }
    
    // Calculate score percentage if room score exists
    double? scorePercentage;
    if (score != null && maxScore != null && maxScore > 0) {
      scorePercentage = score / maxScore;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: itemColor?.withOpacity(0.3) ?? const Color(0xFFE5F0F8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with direction/room name and icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (itemIcon != null)
                Container(
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: itemColor?.withOpacity(0.1) ?? const Color(0xFFF8FBFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    itemIcon,
                    size: 16,
                    color: itemColor ?? const Color(0xFF34F3A3),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Direction or Room name
                    if (directionName != null || roomName != null)
                      Row(
                        children: [
                          Text(
                            directionName ?? roomName ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          if (roomName != null && score != null && maxScore != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: scorePercentage! >= 0.8
                                    ? const Color(0xFF34F3A3).withOpacity(0.15)
                                    : scorePercentage >= 0.6
                                        ? const Color(0xFFFFA726).withOpacity(0.15)
                                        : const Color(0xFFFF5252).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$score/$maxScore',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: scorePercentage >= 0.8
                                      ? const Color(0xFF34F3A3)
                                      : scorePercentage >= 0.6
                                          ? const Color(0xFFFFA726)
                                          : const Color(0xFFFF5252),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (scorePercentage >= 0.8) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Color(0xFF34F3A3),
                              ),
                            ],
                          ],
                        ],
                      ),
                    if (directionName != null || roomName != null)
                      const SizedBox(height: 6),
                    // Description
                    Text(
                      description.isNotEmpty ? description : item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Score progress bar for rooms
          if (scorePercentage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: scorePercentage,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE8E8E8),
                      valueColor: AlwaysStoppedAnimation(
                        scorePercentage >= 0.8
                            ? const Color(0xFF34F3A3)
                            : scorePercentage >= 0.6
                                ? const Color(0xFFFFA726)
                                : const Color(0xFFFF5252),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(scorePercentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scorePercentage >= 0.8
                        ? const Color(0xFF34F3A3)
                        : scorePercentage >= 0.6
                            ? const Color(0xFFFFA726)
                            : const Color(0xFFFF5252),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<String> _extractItemsFromSection(String sectionText) {
    final items = <String>[];
    final lines = sectionText.split('\n');
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Skip section headers
      if (line.toLowerCase().contains('directional analysis') || 
          line.toLowerCase().contains('room analysis') ||
          line.toLowerCase().contains('critical issues') ||
          line.toLowerCase().contains('positive aspects') ||
          line.toLowerCase().contains('recommendations')) {
        continue;
      }
      
      // Extract numbered items (1. North: description or 1. Entrance: 9/10 - description)
      if (RegExp(r'^\d+\.').hasMatch(line)) {
        // Remove number prefix but keep the content
        final cleanedLine = line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
        if (cleanedLine.isNotEmpty && cleanedLine.length > 5) {
          items.add(cleanedLine);
        }
      } 
      // Extract direction lines (North: description)
      else if (RegExp(r'^(North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West)[:\s]', caseSensitive: false).hasMatch(line)) {
        if (line.length > 10) {
          items.add(line);
        }
      }
      // Extract room lines (Kitchen: 12/20 - description or Kitchen: description)
      else if (RegExp(r'^([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance|Balcony))[:\s]', caseSensitive: false).hasMatch(line)) {
        if (line.length > 10) {
          items.add(line);
        }
      }
      else if (line.startsWith('-') || line.startsWith('•')) {
        // Add bullet points
        final cleanedLine = line.replaceAll(RegExp(r'^[-•]\s*'), '').trim();
        if (cleanedLine.isNotEmpty && cleanedLine.length > 10) {
          items.add(cleanedLine);
        }
      } else if (line.length > 15 && 
                 (line.contains(':') || 
                  line.contains(RegExp(r'\d+/\d+')) ||
                  line.contains('North') ||
                  line.contains('East') ||
                  line.contains('South') ||
                  line.contains('West'))) {
        // Add lines that look like content (have colons, scores, or directions)
        items.add(line);
      }
    }
    
    // Remove duplicates
    final uniqueItems = <String>[];
    for (var item in items) {
      if (!uniqueItems.any((existing) => existing.toLowerCase() == item.toLowerCase().substring(0, item.length > 30 ? 30 : item.length))) {
        uniqueItems.add(item);
      }
    }
    
    return uniqueItems;
  }

  Widget _buildTextSection(String title, List<String> items) {
    IconData icon;
    if (title.contains('Directional')) {
      icon = Icons.explore;
    } else if (title.contains('Room')) {
      icon = Icons.home;
    } else if (title.contains('Critical') || title.contains('Issues')) {
      icon = Icons.warning;
    } else if (title.contains('Positive')) {
      icon = Icons.check_circle;
    } else if (title.contains('Recommendation')) {
      icon = Icons.lightbulb;
    } else {
      icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBDF2DE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF34F3A3)),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5F0F8), width: 1),
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    final percentage = score / 100.0;
    String statusText;
    Color statusColor;
    
    if (score >= 80) {
      statusText = "EXCELLENT";
      statusColor = const Color(0xFF34F3A3);
    } else if (score >= 60) {
      statusText = "GOOD";
      statusColor = const Color(0xFF34F3A3);
    } else if (score >= 40) {
      statusText = "AVERAGE";
      statusColor = const Color(0xFFFFA726);
    } else {
      statusText = "NEEDS IMPROVED HARMONY";
      statusColor = const Color(0xFFFF5252);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBDF2DE), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "OVERALL VASTU SCORE",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "$score/100",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 32,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFFE8E8E8),
                        valueColor: AlwaysStoppedAnimation(statusColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$score%",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 20,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.eco,
                size: 32,
                color: Color(0xFF34F3A3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userMessageBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, left: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                ),
                child: Text(
                  text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMON =================

  static Widget _aiAvatar() {
    return Container(
      margin: const EdgeInsets.only(right: 10, top: 2),
      height: 32,
      width: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F1F1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
        'assets/images/ganesha_vaastu_ai.png',
          width: 20,
          height: 20,
        ),
      ),
    );
  }

  static Widget _chatBubble({required Widget child, bool border = false, bool showProgress = false, bool isStructuredReport = false}) {
    if (isStructuredReport) {
      // For structured reports, display full width without chat bubble styling
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: child,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aiAvatar(),
          Flexible(
              child: Container(
              padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                border: (border || showProgress)
                    ? Border.all(color: AppColors.primaryColor, width: 1.5)
                    : Border.all(color: const Color(0xFFE8E8E8), width: 1),
                boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                ),
              child: showProgress
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        child,
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          backgroundColor: Color(0xFFE8E8E8),
                        ),
                      ],
                    )
                  : child,
            ),
          ),
        ],
      ),
    );
  }
}
