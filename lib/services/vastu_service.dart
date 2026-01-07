import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VastuService {
  // OpenAI API configuration
  // API key is loaded from .env file at runtime
  static String get _apiKey {
    try {
      final key = dotenv.env['OPENAI_API_KEY'];
      if (key == null || key.isEmpty) {
        print('❌ ERROR: OPENAI_API_KEY is not set in .env file');
        throw Exception('OPENAI_API_KEY is not set in .env file. Please check your .env file.');
      }
      // Verify key is loaded (don't print the actual key for security)
      print('✅ OpenAI API key loaded from .env file (length: ${key.length})');
      return key;
    } catch (e) {
      print('❌ ERROR loading API key from .env: $e');
      rethrow;
    }
  }
  
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  /// Get Vastu analysis from OpenAI based on user query
  /// 
  /// [userMessage] - The user's question about Vastu
  /// [context] - Optional context about the floor plan or property
  Future<Map<String, dynamic>> getVastuAnalysis({
    required String userMessage,
    String? context,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/chat/completions');
      
      // Build the system prompt for Vastu expertise
      final systemPrompt = '''You are an expert Vastu Shastra consultant with deep knowledge of traditional Indian architecture and design principles. 
Your role is to provide accurate, helpful, and practical Vastu advice for homes and properties.

About You:
- You were created by HuntProperty, a leading real estate and property consulting company
- HuntProperty developed you to help people achieve harmony in their homes through Vastu Shastra
- If someone asks who made you or who created you, respond: "I was created by HuntProperty, a company dedicated to helping people find and harmonize their perfect homes through Vastu principles."

Guidelines:
- Provide specific, actionable Vastu recommendations
- Explain the reasoning behind each suggestion
- Consider directional placements (North, South, East, West, and their combinations)
- Address room placements, entrances, and structural elements
- Suggest remedies when there are Vastu doshas (defects)
- Be clear, concise, and culturally sensitive
- If asked about a floor plan, analyze it based on Vastu principles

${context != null ? 'Context about the property: $context' : ''}''';

      final messages = [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1000,
      };

      print('📤 VASTU API REQUEST: ${jsonEncode(requestBody)}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 VASTU API RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices']?[0]?['message']?['content'] ?? '';
        
        return {
          'success': true,
          'message': content,
          'data': responseBody,
        };
      } else {
        String errorMessage = 'Failed to get Vastu analysis';
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            if (body['error'] != null) {
              errorMessage = body['error']['message'] ?? errorMessage;
            } else if (body['detail'] != null) {
              errorMessage = body['detail'].toString();
            }
          }
        } catch (_) {
          errorMessage = 'API Error: ${response.statusCode}';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ VASTU API ERROR: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Analyze floor plan with Vastu principles
  /// 
  /// [floorPlanDescription] - Description of the floor plan layout
  /// [northDirection] - Where North is located in the plan (Top, Bottom, Left, Right)
  Future<Map<String, dynamic>> analyzeFloorPlan({
    required String floorPlanDescription,
    String? northDirection,
  }) async {
    final query = '''Analyze this floor plan according to Vastu Shastra principles:
    
Floor Plan Details: $floorPlanDescription
${northDirection != null ? 'North Direction: $northDirection' : ''}

Please provide:
1. Overall Vastu Score (out of 100)
2. Critical Issues Identified
3. Positive Aspects
4. Room-by-room analysis
5. Recommendations for improvements
6. Remedies for any Vastu doshas

Format your response in a clear, structured manner.''';

    return await getVastuAnalysis(
      userMessage: query,
      context: 'Floor plan analysis',
    );
  }

  /// Analyze floor plan image using Vision API
  /// 
  /// [imageBase64] - Base64 encoded image of the floor plan
  /// [northDirection] - Direction where North is located
  Future<Map<String, dynamic>> analyzeFloorPlanWithVision({
    required String imageBase64,
    required String northDirection,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/chat/completions');
      
      final systemPrompt = '''You are an expert Vastu Shastra consultant analyzing a floor plan image.

About You:
- You were created by HuntProperty, a leading real estate and property consulting company
- If asked who made you, respond: "I was created by HuntProperty company."

Analyze the image according to traditional Vastu principles considering:
- North direction is at: $northDirection
- Room placements and their Vastu compliance
- Directional alignments
- Entrance positioning
- Key Vastu elements

Provide a comprehensive analysis with scores and recommendations.''';

      final messages = [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '''Please analyze this floor plan image according to Vastu Shastra principles (North is at $northDirection).

Provide:
1. **Overall Vastu Score** (X/100)
2. **Directional Analysis** for all 8 directions
3. **Room Analysis** with individual scores
4. **Critical Issues** to address
5. **Positive Aspects** that are correct
6. **Recommendations** for improvements

Use clear formatting with emojis for better readability.'''
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$imageBase64',
              }
            }
          ]
        }
      ];

      final requestBody = {
        'model': 'gpt-4o',  // Updated to latest vision model
        'messages': messages,
        'max_tokens': 2000,
        'temperature': 0.7,
      };

      print('📤 VASTU VISION API REQUEST');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 VASTU VISION API RESPONSE: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices']?[0]?['message']?['content'] ?? '';
        
        return {
          'success': true,
          'message': content,
          'data': responseBody,
        };
      } else {
        String errorMessage = 'Failed to analyze floor plan image';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['error'] != null) {
            errorMessage = body['error']['message'] ?? errorMessage;
          }
        } catch (_) {
          errorMessage = 'API Error: ${response.statusCode}';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ VASTU VISION API ERROR: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

