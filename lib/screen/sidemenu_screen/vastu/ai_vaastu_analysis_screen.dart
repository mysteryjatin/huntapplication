import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/vastu_service.dart';

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
        text: "Great! I can see your floor plan.",
        isUser: false,
        timestamp: DateTime.now(),
        imagePath: widget.imagePath,
      ));
    });

    _scrollToBottom();

    // Ask for direction after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add(ChatMessage(
          text: "Phase 1: Direction Setup ✓\n\nBefore we analyze, please tell me which direction is NORTH in your image.\n\n👇 Select the North direction below:",
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

  void _selectDirection(String direction) {
    setState(() {
      _selectedDirection = direction;
      
      // Add user's selection
      _messages.add(ChatMessage(
        text: "I selected: $direction",
        isUser: true,
        timestamp: DateTime.now(),
      ));

      // Show analyzing message
      _messages.add(ChatMessage(
        text: "Analyzing with North at $direction ✓\n\nPhase 2: Detecting rooms and analyzing structure...\n\nThis may take 10-15 seconds as I analyze your floor plan using AI...",
        isUser: false,
        timestamp: DateTime.now(),
        showProgress: true,
      ));
    });

    _scrollToBottom();

    // Perform real AI analysis
    _performAIAnalysis(direction);
  }

  Future<void> _performAIAnalysis(String direction) async {
    try {
      Map<String, dynamic> response;

      // Check if we have an image to analyze
      if (widget.imagePath != null) {
        // Try to use Vision API for image analysis
        try {
          final imageBytes = await File(widget.imagePath!).readAsBytes();
          final imageBase64 = base64Encode(imageBytes);

          response = await _vastuService.analyzeFloorPlanWithVision(
            imageBase64: imageBase64,
            northDirection: direction,
          );
        } catch (visionError) {
          print('Vision API not available, using text-based analysis: $visionError');
          
          // Fallback to text-based analysis
          final query = '''I have uploaded a floor plan image with North direction at $direction.

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
          
          // Add completion message
          _messages.add(ChatMessage(
            text: "Phase 3: Vaastu Analysis Complete! ✅\n\nHere's your AI-powered detailed Vaastu report:",
            isUser: false,
            timestamp: DateTime.now(),
          ));

          // Add the AI analysis
          _messages.add(ChatMessage(
            text: analysisText,
            isUser: false,
            timestamp: DateTime.now(),
          ));

          // Add next steps
          _messages.add(ChatMessage(
            text: "💡 What's Next?\n\nYou can:\n1. Ask me specific questions about any room\n2. Get detailed remedies for problem areas\n3. Request clarification on any aspect\n4. Learn more about specific Vastu principles\n\nJust type your question below!",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        } else {
          // Show error message
          _messages.add(ChatMessage(
            text: "❌ Analysis Error\n\nI encountered an issue while analyzing your floor plan: ${response['error'] ?? 'Unknown error'}\n\nPlease try again or ask me any specific Vastu questions!",
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
          text: "❌ Analysis Error\n\nSomething went wrong: $e\n\nPlease try again or ask me any specific Vastu questions!",
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
        _messages.add(ChatMessage(
          text: response['message'] ?? 'No response received',
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
                  return Column(
                    children: [
                      _chatBubble(
                        child: _formatMessage(message.text),
                        showProgress: message.showProgress,
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

          /// INPUT BAR
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 40, left: 42),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: directions.map((direction) {
          final isSelected = _selectedDirection == direction;
          return InkWell(
            onTap: isSelected ? null : () => _selectDirection(direction),
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
                    Icons.navigation,
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
                      line.startsWith('✅') ||
                      line.startsWith('⚠️') ||
                      line.startsWith('📊') ||
                      line.startsWith('🧭') ||
                      line.startsWith('🏠') ||
                      line.startsWith('✨') ||
                      line.startsWith('💡') ||
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

  static Widget _chatBubble({required Widget child, bool border = false, bool showProgress = false}) {
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
                border: border || showProgress
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
