import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  
  // Grok Mode: "Stress Mode" effectively becomes "Pro Mode" (Green Accent)
  // Standard Mode: White Accent
  bool _isStressMode = false;
  
  String get _apiUrl => _isStressMode 
      ? 'http://10.123.238.189:8000/api/doc-chat/' 
      : 'http://10.123.238.189:8000/api/chat/';
  
  // Theme Colors
  Color get _accentColor => _isStressMode ? const Color(0xFF00FF41) : Colors.white; // Neon Green or Pure White
  
  final String _sessionId = 'user_${Random().nextInt(10000)}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _sendWelcomeMessage();
  }

  void _sendWelcomeMessage() {
    _addMessage('bot', 'MAA ONLINE. SYSTEM READY.\nHow can I help you today?');
  }

  void _addMessage(String sender, String text) {
    setState(() {
      _messages.add(ChatMessage(sender: sender, text: text, accentColor: _accentColor));
    });
  }

  Future<void> _sendMessage(String query) async {
    if (query.isEmpty) return;

    _addMessage('user', query);
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': _sessionId, 'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addMessage('bot', data['response']);
      } else {
        _addMessage('bot', 'SERVER ERROR: ${response.statusCode}');
      }
    } catch (e) {
      _addMessage('bot', 'CONNECTION FAILED. CHECK TERMINAL.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure Black Background
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.blur_on, color: _isStressMode ? _accentColor : Colors.white, size: 28), // Abstract Brain/AI Logo
            const SizedBox(width: 8),
            Text(
              'MAA',
              style: TextStyle(
                fontWeight: FontWeight.w900, // Extra Bold
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Icon(Icons.security, color: _isStressMode ? _accentColor : Colors.grey[800]),
        actions: [
          IconButton(
            icon: Icon(
              _isStressMode ? Icons.toggle_on : Icons.toggle_off, 
              color: _accentColor,
            ),
            onPressed: () {
              setState(() {
                _isStressMode = !_isStressMode;
                _messages.clear();
                _isStressMode 
                    ? _addMessage('bot', 'PRO MODE ACTIVE.\nACCESSING EXPERT DATABASE...')
                    : _sendWelcomeMessage();
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[900]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'Enter command...',
                hintStyle: TextStyle(color: Colors.grey[700], fontFamily: 'monospace'),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded rectangles, not pills
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.black),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String sender;
  final String text;
  final Color accentColor;

  const ChatMessage({super.key, required this.sender, required this.text, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isUser = sender == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isUser ? 'YOU' : 'MAA',
            style: TextStyle(
              color: isUser ? Colors.grey[500] : accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: isUser 
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              : const EdgeInsets.only(right: 32), // AI text needs breathing room
            decoration: isUser ? BoxDecoration(
              color: Colors.white, // High contrast user bubble
              borderRadius: BorderRadius.circular(12),
            ) : null, // AI text has NO bubble, just text (minimalist)
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.black : Colors.white,
                fontSize: 16,
                height: 1.4,
                // AI uses default font for readability, User uses default
              ),
            ),
          ),
        ],
      ),
    );
  }
}
