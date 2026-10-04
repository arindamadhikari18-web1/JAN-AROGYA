import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/app_theme.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() =>
      _AiChatbotScreenState();
}

class _AiChatbotScreenState
    extends State<AiChatbotScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  bool _isLoading = false;

  // ==========================================
  // RENDER BACKEND URL
  // ==========================================

  static const String _baseUrl =
      'https://jan-arogya-ai.onrender.com';

  // ==========================================
  // INITIAL CHAT MESSAGE
  // ==========================================

  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'message':
          'Hello! 👋 I am Jan Arogya AI Assistant. How can I help you with your health today?',
    },
  ];

  // ==========================================
  // SEND MESSAGE
  // ==========================================

  Future<void> _sendMessage() async {
    final String message =
        _messageController.text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.add({
        'role': 'user',
        'message': message,
      });

      _isLoading = true;
    });

    _messageController.clear();

    _scrollToBottom();

    try {
      final Uri apiUrl =
          Uri.parse('$_baseUrl/api/chat');

      debugPrint('Sending request to: $apiUrl');

      final response = await http
          .post(
            apiUrl,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': message,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
          );

      debugPrint(
        'Server status: ${response.statusCode}',
      );

      debugPrint(
        'Server response: ${response.body}',
      );

      String aiMessage;

      // ======================================
      // SUCCESS RESPONSE
      // ======================================

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        if (data['success'] == true) {
          aiMessage =
              data['reply']?.toString().trim() ??
                  'Sorry, I could not generate a response.';

          if (aiMessage.isEmpty) {
            aiMessage =
                'Sorry, I received an empty response. Please try again.';
          }
        } else {
          aiMessage =
              data['error']?.toString() ??
                  'Sorry, something went wrong.';
        }
      }

      // ======================================
      // OTHER SERVER ERRORS
      // ======================================

      else {
        try {
          final Map<String, dynamic> data =
              jsonDecode(response.body);

          aiMessage =
              data['error']?.toString() ??
                  'Server error (${response.statusCode}). Please try again.';
        } catch (_) {
          aiMessage =
              'Server error (${response.statusCode}). Please try again.';
        }
      }

      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'ai',
          'message': aiMessage,
        });

        _isLoading = false;
      });

      _scrollToBottom();
    }

    // ========================================
    // CONNECTION / TIMEOUT ERROR
    // ========================================

    catch (e) {
      debugPrint('AI connection error: $e');

      if (!mounted) return;

      String errorMessage;

      if (e.toString().contains('TimeoutException')) {
        errorMessage =
            'The AI server is taking too long to respond. Please try again.';
      } else {
        errorMessage =
            'Unable to connect to the AI server. Please check your internet connection and try again.';
      }

      setState(() {
        _messages.add({
          'role': 'ai',
          'message': errorMessage,
        });

        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  // ==========================================
  // SCROLL TO BOTTOM
  // ==========================================

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 250),
      () {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      },
    );
  }

  // ==========================================
  // CLEAR CHAT
  // ==========================================

  void _clearChat() {
    setState(() {
      _messages.clear();

      _messages.add({
        'role': 'ai',
        'message':
            'Hello! 👋 I am Jan Arogya AI Assistant. How can I help you with your health today?',
      });
    });

    _scrollToBottom();
  }

  // ==========================================
  // MESSAGE BUBBLE
  // ==========================================

  Widget _buildMessageBubble(
    Map<String, String> message,
  ) {
    final bool isUser =
        message['role'] == 'user';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primary
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: isUser
                    ? null
                    : Border.all(
                        color:
                            const Color(0xFFE8EDF2),
                      ),
              ),
              child: Text(
                message['message'] ?? '',
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // TYPING INDICATOR
  // ==========================================

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE8EDF2),
              ),
            ),
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SUGGESTION CHIP
  // ==========================================

  Widget _buildSuggestion(String text) {
    return InkWell(
      onTap: _isLoading
          ? null
          : () {
              _messageController.text = text;
              _sendMessage();
            },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(
          right: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primary
                .withOpacity(0.15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // MAIN UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Jan Arogya AI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'Your AI Health Assistant',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: Column(
        children: [
          // ====================================
          // AI INFORMATION CARD
          // ====================================

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Ask me about general health, medicines, fitness and healthy lifestyle.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====================================
          // SUGGESTION CHIPS
          // ====================================

          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              children: [
                _buildSuggestion(
                  'How can I stay healthy?',
                ),

                _buildSuggestion(
                  'Tips for better sleep',
                ),

                _buildSuggestion(
                  'Healthy diet tips',
                ),

                _buildSuggestion(
                  'How much water should I drink?',
                ),
              ],
            ),
          ),

          // ====================================
          // CHAT AREA
          // ====================================

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12,
              ),
              itemCount:
                  _messages.length +
                      (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }

                return _buildMessageBubble(
                  _messages[index],
                );
              },
            ),
          ),

          // ====================================
          // MESSAGE INPUT
          // ====================================

          SafeArea(
            top: false,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE8EDF2),
                  ),
                ),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _messageController,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !_isLoading,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Ask your health question...',
                        filled: true,
                        fillColor:
                            const Color(0xFFF8FAFC),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isLoading
                          ? null
                          : _sendMessage,
                      icon: Icon(
                        _isLoading
                            ? Icons.hourglass_top_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
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
}