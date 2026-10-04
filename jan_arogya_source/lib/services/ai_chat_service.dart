import 'dart:convert';

import 'package:http/http.dart' as http;

class AiChatService {
  // =====================================================
  // RENDER BACKEND URL
  // =====================================================

  static const String baseUrl =
      'https://jan-arogya-ai.onrender.com';

  // =====================================================
  // SEND MESSAGE TO AI
  // =====================================================

  static Future<String> sendMessage(String message) async {
    try {
      final String cleanMessage = message.trim();

      if (cleanMessage.isEmpty) {
        return 'Please enter a message.';
      }

      final Uri url = Uri.parse('$baseUrl/api/chat');

      final response = await http
          .post(
            url,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': cleanMessage,
            }),
          )
          .timeout(
            const Duration(seconds: 90),
          );

      // =====================================================
      // DECODE RESPONSE
      // =====================================================

      Map<String, dynamic> data = {};

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        return 'Invalid response received from the AI server.';
      }

      // =====================================================
      // SUCCESS
      // Expected backend response:
      // {
      //   "success": true,
      //   "reply": "AI response here"
      // }
      // =====================================================

      if (response.statusCode == 200 &&
          data['success'] == true) {
        final String reply =
            data['reply']?.toString().trim() ?? '';

        if (reply.isNotEmpty) {
          return reply;
        }

        return 'Sorry, I could not generate a response.';
      }

      // =====================================================
      // BACKEND ERROR
      // =====================================================

      final String errorMessage =
          data['error']?.toString().trim() ?? '';

      if (errorMessage.isNotEmpty) {
        return errorMessage;
      }

      return 'Server error (${response.statusCode}). '
          'Please try again.';
    } on http.ClientException {
      return 'Unable to connect to the AI assistant. '
          'Please check your internet connection.';
    } catch (_) {
      return 'Unable to connect to the AI assistant. '
          'Please try again.';
    }
  }
}