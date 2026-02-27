import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/feature_info_sheet.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  _GroundingScreenState createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fiveSeeController = TextEditingController();
  final _fourTouchController = TextEditingController();
  final _threeHearController = TextEditingController();
  final _twoSmellController = TextEditingController();
  final _oneTasteController = TextEditingController();
  final _feedbackController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final ApiService _apiService = ApiService();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5);
    _tts.speak('Let’s start the 5-4-3-2-1 grounding exercise.');
  }

  @override
  void dispose() {
    _fiveSeeController.dispose();
    _fourTouchController.dispose();
    _threeHearController.dispose();
    _twoSmellController.dispose();
    _oneTasteController.dispose();
    _feedbackController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _tts.speak('Good job. Let’s move to the next step.');
      setState(() => _step++);
      if (_step > 5) _logSession();
    }
  }

  bool _isSaving = false;

  Future<void> _logSession() async {
    setState(() => _isSaving = true);
    
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    try {
      final response = await _apiService.logGroundingSession(
        fiveSee: _fiveSeeController.text,
        fourTouch: _fourTouchController.text,
        threeHear: _threeHearController.text,
        twoSmell: _twoSmellController.text,
        oneTaste: _oneTasteController.text,
        feedback: _feedbackController.text,
      );
      
      if (mounted) {
        Navigator.pop(context); // close loading dialog
        
        final aiFeedback = response['feedback'];
        if (aiFeedback != null && aiFeedback.toString().isNotEmpty) {
           _showResponseModal(aiFeedback.toString());
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session saved!')));
           Navigator.pop(context); // close screen
        }
      }
    } catch (e) {
      if (mounted) {
         Navigator.pop(context); // close loading dialog
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logging failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showResponseModal(String aiText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text("MAA's Reflection", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  aiText,
                  style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textDark, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: "Done",
              onPressed: () {
                Navigator.pop(context); // Close bottom sheet
                Navigator.pop(context); // Close Grounding Screen
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [
      _buildStepField(_fiveSeeController, '5 things you can see 👁️', 'Enter 5 things', 'Look around and notice 5 things you can see.'),
      _buildStepField(_fourTouchController, '4 things you can touch 🖐️', 'Enter 4 things', 'Notice 4 sensations you can feel on your body.'),
      _buildStepField(_threeHearController, '3 things you can hear 👂', 'Enter 3 things', 'Listen carefully for 3 sounds around you.'),
      _buildStepField(_twoSmellController, '2 things you can smell 👃', 'Enter 2 things', 'Try to notice 2 scents in the air.'),
      _buildStepField(_oneTasteController, '1 thing you can taste 👅', 'Enter 1 thing', 'Focus on one taste in your mouth.'),
      _buildStepField(_feedbackController, 'Feedback (optional)', null, 'How are you feeling now?'),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevent keyboard from shifting background too much
      appBar: AppBar(
        title: Text('Grounding', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textDark),
            onPressed: () => FeatureInfoSheet.show(context, 'grounding'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF3E5F5)], // Soft Cyan to Soft Lavender
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / 6,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Step ${_step + 1} of 6", 
                    style: GoogleFonts.outfit(color: AppTheme.textLight, fontWeight: FontWeight.w500)
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Card Content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: GlassCard(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "5-4-3-2-1 Technique",
                                  style: GoogleFonts.outfit(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w600, 
                                    color: AppTheme.primaryColor
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_step < steps.length) steps[_step],
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  GradientButton(
                    text: _isSaving ? 'Reflecting with MAA...' : (_step < 5 ? 'Next Step' : 'Finish Session'),
                    onPressed: _isSaving ? () {} : (_step < 5 || _step == 5 ? (_step < 5 ? _nextStep : _logSession) : () {}),
                    icon: _step < 5 ? Icons.arrow_forward_rounded : Icons.check_rounded,
                  ),
                  // Keyboard spacer if needed, or rely on resizeToAvoidBottomInset
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepField(TextEditingController controller, String label, String? errorMsg, String description) {
    return Column(
      children: [
        Text(
          label, 
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        CustomTextField(
          controller: controller,
          hintText: "Reflect here...",
          maxLines: 4,
          validator: errorMsg != null ? (val) => val!.isEmpty ? errorMsg : null : null,
        ),
      ],
    );
  }
}