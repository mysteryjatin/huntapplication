import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/vastu_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiVaastuAnalysisScreen extends StatefulWidget {
  const AiVaastuAnalysisScreen({super.key});

  @override
  State<AiVaastuAnalysisScreen> createState() => _AiVaastuAnalysisScreenState();
}

class _AiVaastuAnalysisScreenState extends State<AiVaastuAnalysisScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VastuService _vastuService = VastuService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial welcome message
    _messages.add(ChatMessage(
      text: "I'm your personal AI Vaastu consultant. I'll guide you step-by-step to analyze your home.\n\nHow This Works (5–7 minutes total)\n• Phase 1: Direction Setup\n• Phase 2: Room Mapping\n• Phase 3: Vaastu Analysis\n\nYou can ask me anything about Vastu Shastra, and I'll provide expert advice!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
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
      backgroundColor: const Color(0xFFF4FAFE),

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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  return _chatBubble(
                    child: _formatMessage(message.text),
                  );
                }
              },
            ),
          ),

          /// INPUT BAR
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ask anything about Vaastu...",
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 13),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.grey : AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      "Send",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
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

  Widget _formatMessage(String text) {
    // Split by newlines and format
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 4);
        }
        final isBold = line.startsWith('•') || 
                      line.contains(':') && (line.contains('Score') || line.contains('Issues') || line.contains('Aspects'));
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _userMessageBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 28,
            width: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0E0E0),
            ),
            child: const Icon(Icons.person, size: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ================= COMMON =================

  static Widget _aiAvatar() {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      height: 28,
      width: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F1F1),
      ),
      child: const Icon(Icons.psychology,
          size: 18, color: Colors.brown),
    );
  }

  static Widget _chatBubble({required Widget child, bool border = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aiAvatar(),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: border
                      ? Border.all(color: AppColors.primaryColor)
                      : null,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
