import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'drawing_canvas_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../art_therapy_screen.dart';

class DrawingChoiceScreen extends StatefulWidget {
  const DrawingChoiceScreen({super.key});

  @override
  State<DrawingChoiceScreen> createState() => _DrawingChoiceScreenState();
}

class _DrawingChoiceScreenState extends State<DrawingChoiceScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  String? _selectedMode; // 'Free', 'Prompt', or 'Coloring'
  int? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final sessions = await _apiService.getTherapySessions('Drawing');
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint("Error fetching drawing sessions: $e");
    }
  }

  void _startDrawing() {
    if (_selectedMode == 'Coloring') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArtTherapyScreen()),
      );
      return;
    }

    if (_selectedMode == 'Free') {
       if (_selectedSessionId == null && _sessions.isNotEmpty) {
           _selectedSessionId = _sessions.first['id']; 
       }
    }

    if (_selectedSessionId == null && _sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No drawing sessions available.")));
      return;
    }
    
    final session = _sessions.firstWhere((s) => s['id'] == _selectedSessionId, orElse: () => _sessions.first);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawingCanvasScreen(
          session: session,
          isFreeDraw: _selectedMode == 'Free',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Art Therapy', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Express yourself",
                style: GoogleFonts.outfit(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose how you want to create today.",
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
              ),
              const SizedBox(height: 30),
              
              // Mode Selection
              Row(
                children: [
                   Expanded(
                    child: _buildModeCard(
                      title: 'Coloring', 
                      icon: Icons.format_paint_rounded, 
                      mode: 'Coloring'
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeCard(
                      title: 'Free Draw', 
                      icon: Icons.brush_rounded, 
                      mode: 'Free'
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeCard(
                      title: 'Guided', 
                      icon: Icons.lightbulb_rounded, 
                      mode: 'Prompt'
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // Session List (Only if Prompt Mode)
              if (_selectedMode == 'Prompt') ...[
                Text(
                  "Select a Prompt", 
                  style: GoogleFonts.outfit(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark
                  )
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : ListView.builder(
                      itemCount: _sessions.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final isSelected = _selectedSessionId == session['id'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GlassCard(
                            onTap: () => setState(() => _selectedSessionId = session['id']),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    session['title'], 
                                    style: GoogleFonts.outfit(
                                      color: isSelected ? AppTheme.textDark : AppTheme.textLight,
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ),
              ] else 
                 const Spacer(),

              const SizedBox(height: 20),
              GradientButton(
                text: "Open Canvas",
                onPressed: _selectedMode != null ? _startDrawing : null,
                icon: Icons.palette_rounded,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({required String title, required IconData icon, required String mode}) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMode = mode;
        if (mode == 'Free' || mode == 'Coloring') _selectedSessionId = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: 32, 
                color: isSelected ? Colors.white : AppTheme.primaryColor
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16, 
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
