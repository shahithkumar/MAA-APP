import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class MAAChatScreen extends StatefulWidget {
  const MAAChatScreen({super.key});

  @override
  State<MAAChatScreen> createState() => _MAAChatScreenState();
}

class _MAAChatScreenState extends State<MAAChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  
  String _currentMode = "friend"; 
  
  String get _baseUrl => _apiService.baseUrl;
  String get _apiUrl => '$_baseUrl/api/chat/';
  
  Color get _accentColor {
    if (_currentMode == "guide") return const Color(0xFF64B5F6); // Soft Blue
    if (_currentMode == "normal") return const Color(0xFF81C784); // Soft Green
    return AppTheme.primaryColor; // Default Purple
  }
  
  final String _sessionId = 'user_${Random().nextInt(10000)}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _sendWelcomeMessage();
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

  void _sendWelcomeMessage() {
    String msg;
    if (_currentMode == "guide") {
      msg = "I'm in Guide Mode. I'm here to help you navigate specific feelings with care.";
    } else if (_currentMode == "normal") {
      msg = "Hello. I am MAA Standard. How can I assist you with information today?";
    } else {
      msg = "Hi! I'm here to listen. This is a safe space. What's on your mind? ✨";
    }
    _addMessage('bot', msg);
  }

  void _addMessage(String sender, String text) {
    setState(() {
      _messages.add(ChatMessage(sender: sender, text: text, accentColor: _accentColor));
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage(String query) async {
    if (query.isEmpty) return;

    _addMessage('user', query);
    _controller.clear();
    setState(() => _isLoading = true);

    try {
      final responseText = await _apiService.sendChatMessage(_sessionId, query, _currentMode);
      _addMessage('bot', responseText);
    } catch (e) {
      _addMessage('bot', 'I encountered an error connecting to my cognitive layer. Please try again soon. ✨');
      print('Chat Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setMode(String mode) {
    if (_currentMode == mode) return;
    setState(() {
      _currentMode = mode;
      _messages.clear();
      _sendWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Ensure light background
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'MAA Chat',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentMode.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history_rounded, color: AppTheme.textDark),
              tooltip: 'Chat History',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textDark),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: _setMode,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'friend', 
                child: Row(children: [Text('Friend Mode', style: GoogleFonts.outfit()), Spacer(), if(_currentMode=='friend') Icon(Icons.check, color: AppTheme.primaryColor)])
              ),
              PopupMenuItem(
                value: 'guide', 
                child: Row(children: [Text('Guide Mode', style: GoogleFonts.outfit()), Spacer(), if(_currentMode=='guide') Icon(Icons.check, color: AppTheme.primaryColor)])
              ),
              PopupMenuItem(
                value: 'normal', 
                child: Row(children: [Text('Standard Mode', style: GoogleFonts.outfit()), Spacer(), if(_currentMode=='normal') Icon(Icons.check, color: AppTheme.primaryColor)])
              ),
            ],
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20),
              width: double.infinity,
              decoration: BoxDecoration(color: _accentColor.withOpacity(0.9)),
              child: Center(
                child: Text(
                  'Chat History\n(${_currentMode.toUpperCase()})',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _apiService.getChatHistory(mode: _currentMode),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: _accentColor));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading history', style: GoogleFonts.outfit(color: AppTheme.errorColor)));
                  }
                  final sessions = snapshot.data ?? [];
                  if (sessions.isEmpty) {
                    return Center(child: Text('No history found.', style: GoogleFonts.outfit(color: AppTheme.textLight)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sessions.length,
                    separatorBuilder: (_,__) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: _accentColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.chat_bubble_outline_rounded, color: _accentColor, size: 20),
                        ),
                        title: Text(
                          session['title'] ?? 'New Chat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                        ),
                        subtitle: Text(
                          session['created_at'].toString().substring(0, 10),
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight),
                        ),
                        onTap: () async {
                          Navigator.pop(context); // Close drawer
                          _loadSession(session['session_id']);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return ChatLoadingBubble(accentColor: _accentColor); 
                }
                return _messages[index];
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Future<void> _loadSession(String sessionId) async {
    setState(() => _isLoading = true);
    try {
      final messages = await _apiService.getChatMessages(sessionId);
      setState(() {
        _messages.clear();
        for (var msg in messages) {
          _messages.add(ChatMessage(
            sender: msg['sender'], 
            text: msg['content'], 
            accentColor: _accentColor
          ));
        }
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load session', style: GoogleFonts.outfit())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA), // Very light grey instead of white over white
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.outfit(color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.outfit(color: AppTheme.textLight),
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _sendMessage(_controller.text),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _accentColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced vertical pad for tighter chat
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: accentColor.withOpacity(0.2)),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bot_avatar.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  color: isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatLoadingBubble extends StatelessWidget {
  final Color accentColor;
  const ChatLoadingBubble({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
         Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/images/bot_avatar.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: accentColor.withOpacity(0.5))),
                 const SizedBox(width: 8),
                 Text('MAA is thinking...', style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 13, fontStyle: FontStyle.italic)),
               ],
             ),
          ),
        ],
      ),
    );
  }
}
