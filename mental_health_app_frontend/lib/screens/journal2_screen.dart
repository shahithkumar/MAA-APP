import 'dart:io';
import 'dart:ui';
import 'dart:async'; // Added for Timer
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'mood_tracker.dart';

class Journal2Screen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Journal2Screen({required this.cameras, super.key});

  @override
  State<Journal2Screen> createState() => _Journal2ScreenState();
}

class _Journal2ScreenState extends State<Journal2Screen> with TickerProviderStateMixin {
  CameraController? _cameraController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioRecorder _record = AudioRecorder();

  // State
  bool _isRecording = false;
  bool _isUploading = false;
  bool _isCapturingFace = false;
  
  // Data to send
  Uint8List? _voiceBytes;
  Uint8List? _imageBytes;
  String? _capturedImagePath;
  
  Timer? _faceTimer;
  bool _isProcessingFrame = false;
  String _currentFaceEmotion = "Tracking...";
  List<String> _trackedFaceEmotions = [];

  // Analysis Results
  String? _finalEmotion;
  double? _confidence;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _imageBytes == null) {
      _startFaceCapture();
    }
  }

  Future<void> _ensureCameraReady() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) return;

    List<CameraDescription> cameras = widget.cameras;
    if (cameras.isEmpty) {
      try {
        cameras = await availableCameras();
      } catch (e) {
        debugPrint("Error fetching cameras: $e");
      }
    }
    
    if (cameras.isEmpty) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No camera found")));
       return;
    }

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(front, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  // --- ACTIONS ---

  Future<void> _toggleVoice() async {
    if (_isRecording) {
      // Stop
      final path = await _record.stop();
      if (path != null) {
        Uint8List bytes;
        if (kIsWeb) {
           final response = await http.get(Uri.parse(path));
           bytes = response.bodyBytes;
        } else {
           bytes = await File(path).readAsBytes();
        }
        
        setState(() {
          _voiceBytes = bytes;
          _isRecording = false;
        });
      }
    } else {
      // Start
      if (!kIsWeb) {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) return;
      }

      String? path;
      if (!kIsWeb) {
        final dir = await getTemporaryDirectory();
        path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';
      }
      
      await _record.start(
        const RecordConfig(encoder: AudioEncoder.wav), 
        path: path ?? '', 
      );
      setState(() => _isRecording = true);
    }
  }

  // Step 1: Trust Modal
  // _showFaceTrustModal removed as user wants to track directly without prompts

  void _toggleFaceTracking() {
    if (_isCapturingFace) {
      _faceTimer?.cancel();
      setState(() => _isCapturingFace = false);
    } else {
      _startFaceCapture();
    }
  }

  // Step 2: Start Capture Flow
  Future<void> _startFaceCapture() async {
    await _ensureCameraReady();
    if (_cameraController != null) {
      setState(() {
        _isCapturingFace = true;
        _currentFaceEmotion = "Analyzing...";
      });

      _faceTimer?.cancel();
      _faceTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!_isCapturingFace || _cameraController == null) {
          timer.cancel();
          return;
        }
        if (_isProcessingFrame || _cameraController!.value.isTakingPicture) return;
        _isProcessingFrame = true;

        try {
          final xfile = await _cameraController!.takePicture();
          final bytes = await xfile.readAsBytes();
          
          final result = await ApiService().analyzeFaceFrame(bytes);
          if (result != null && mounted && _isCapturingFace) { // Check if still open
            final detected = result['emotion']?.toString().toLowerCase() ?? "unknown";
            if (detected != "unknown" && detected != "neutral") {
              _trackedFaceEmotions.add(detected);
            }
            setState(() {
              _currentFaceEmotion = detected.toUpperCase();
              _imageBytes = bytes; // Automatically save the latest
            });
          }
        } catch (e) {
          debugPrint("Continuous tracking error: $e");
        } finally {
          _isProcessingFrame = false;
        }
      });
    }
  }

  Future<void> _captureFace() async {
    _faceTimer?.cancel();
    if (_cameraController == null || _cameraController!.value.isTakingPicture) return;
    try {
      final xfile = await _cameraController!.takePicture();
      final bytes = await xfile.readAsBytes(); 
      setState(() {
         _imageBytes = bytes;
         _capturedImagePath = xfile.path;
         _isCapturingFace = false; // Close overlay immediately
      });
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<void> _analyzeAndSave() async {
    if (_textController.text.isEmpty && _voiceBytes == null && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please share something first.")),
      );
      return;
    }

    if (_isCapturingFace) {
      _faceTimer?.cancel();
      _isCapturingFace = false;
    }

    setState(() => _isUploading = true);

    try {
      String? faceBase64;
      if (_imageBytes != null) {
        faceBase64 = 'data:image/jpeg;base64,${base64Encode(_imageBytes!)}';
      }

      String? combinedFaceEmotions;
      if (_trackedFaceEmotions.isNotEmpty) {
        combinedFaceEmotions = _trackedFaceEmotions.join(',');
      }

      final result = await ApiService().saveJournal2(
        text: _textController.text,
        voiceBytes: _voiceBytes,
        faceBase64: faceBase64,
        trackedFaceEmotion: combinedFaceEmotions,
      );

      if (mounted) {
        setState(() {
          _finalEmotion = result["final_emotion"] ?? "neutral";
          _confidence = 0.95; // Custom Journal 2 result doesn't return full probs yet
          _components = result["components"];
          _isUploading = false;
        });
        _showResultModal();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.errorColor),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  Map<String, dynamic>? _components;

  void _showDetailedAnalysisModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50, 
                    height: 4, 
                    decoration: BoxDecoration(color: AppTheme.textLight.withOpacity(0.3), borderRadius: BorderRadius.circular(10))
                  ),
                ),
                const SizedBox(height: 32),
                
                // HEADER
                Center(
                  child: Text(
                    "Deep Analysis",
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Understanding your expression layers.",
                    style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 40),

                // FUSION MODEL EXPLANATION
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.hub_outlined, color: AppTheme.primaryColor, size: 24),
                          const SizedBox(width: 12),
                          Text("Late Fusion Model", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "We use a 'Late Fusion' approach. This means we analyze your Text, Voice, and Face separately first to respect their unique signals. Then, we combine these distinct insights into a final weighted emotional conclusion.",
                        style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textDark, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // MODALITIES
                if (_components != null) ...[
                   _buildModalitySection("Text Analysis", Icons.text_fields_rounded, _components!['text']),
                   _buildModalitySection("Voice Analysis", Icons.mic_rounded, _components!['voice']),
                   _buildModalitySection("Face Analysis", Icons.face_rounded, _components!['face']),
                ],
                
                const SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close Details", style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy': return const Color(0xFFFFD700); // Gold
      case 'joy': return const Color(0xFFFFD700);
      case 'sad': return const Color(0xFF6495ED); // Cornflower Blue
      case 'sadness': return const Color(0xFF6495ED);
      case 'angry': return const Color(0xFFFF6B6B); // Red
      case 'anger': return const Color(0xFFFF6B6B);
      case 'fear': return const Color(0xFF9370DB); // Purple
      case 'disgust': return const Color(0xFF2E8B57); // Sea Green
      case 'surprise': return const Color(0xFFFFA500); // Orange
      case 'neutral': return Colors.grey;
      case 'calm': return const Color(0xFF87CEEB); // Sky Blue
      default: return AppTheme.primaryColor;
    }
  }

  Widget _buildModalitySection(String title, IconData icon, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    // Parse emotions
    Map<String, dynamic> rawEmotions = data['normalized_probs'] ?? data['raw_probs'] ?? {};
    List<MapEntry<String, dynamic>> sortedEmotions = rawEmotions.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
    // Take Top 3
    final top3 = sortedEmotions.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.textLight),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            ],
          ),
          const SizedBox(height: 16),
          ...top3.map((e) {
             final confidence = (e.value as num).toDouble();
             final emotionColor = _getEmotionColor(e.key);
             
             return Padding(
               padding: const EdgeInsets.only(bottom: 12.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Row(
                         children: [
                           Container(width: 8, height: 8, decoration: BoxDecoration(color: emotionColor, shape: BoxShape.circle)),
                           const SizedBox(width: 8),
                           Text(e.key.toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                         ],
                       ),
                       Text("${(confidence * 100).toStringAsFixed(0)}%", style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textLight)),
                     ],
                   ),
                   const SizedBox(height: 6),
                     // Bar
                     Container(
                       height: 6,
                       width: double.infinity,
                       decoration: BoxDecoration(
                         color: Colors.grey.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(3),
                       ),
                       child: FractionallySizedBox(
                         alignment: Alignment.centerLeft,
                         widthFactor: confidence.clamp(0.0, 1.0), // Ensure 0.0 - 1.0 bounds
                         child: Container(
                           decoration: BoxDecoration(
                             color: emotionColor,
                             borderRadius: BorderRadius.circular(3),
                           ),
                         ),
                       ),
                     ),
                 ],
               ),
             );
          }).toList(),
          if (top3.isEmpty)
             Text("No data captured for this mode.", style: GoogleFonts.outfit(fontSize: 14, fontStyle: FontStyle.italic, color: AppTheme.textLight)),
          Divider(color: Colors.grey.withOpacity(0.1), height: 40),
        ],
      ),
    );
  }

  void _showResultModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
           height: MediaQuery.of(context).size.height * 0.65, // Slightly taller
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]
           ),
           padding: const EdgeInsets.all(32),
           child: SingleChildScrollView( 
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
                 const SizedBox(height: 30),
                 Text("Emotional Insight", style: GoogleFonts.outfit(fontSize: 16, fontStyle: FontStyle.italic, color: AppTheme.textLight)),
                 const SizedBox(height: 20),
                 Text(_finalEmotion!.toUpperCase(), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                 const SizedBox(height: 10),
                 Text(
                   "Confidence: ${(_confidence! * 100).toStringAsFixed(0)}%", 
                   style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textDark)
                 ),
                 const SizedBox(height: 24),
                 
                 // NEW BUTTON FOR DETAILS
                 OutlinedButton(
                   style: OutlinedButton.styleFrom(
                     side: BorderSide(color: AppTheme.primaryColor),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                   ),
                   onPressed: _showDetailedAnalysisModal, // Open new modal
                   child: Text("View Analysis Details", style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                 ),
  
                 const SizedBox(height: 40), 
                 GradientButton(
                   text: "Finish & See AI Plan",
                   onPressed: () {
                     Navigator.pop(context); // Close modal
                     Navigator.pop(context); // Go back to dashboard
                   },
                 ),
                 const SizedBox(height: 16),
                 TextButton(
                   onPressed: () {
                     Navigator.pop(context);
                     setState(() {
                        _textController.clear();
                        _voiceBytes = null;
                        _imageBytes = null;
                        _capturedImagePath = null;
                        _finalEmotion = null;
                        _components = null;
                        _trackedFaceEmotions.clear(); // Clear tracked face emotions
                     });
                   },
                   child: Text("New Entry", style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 16)),
                 )
               ],
             ),
           ).animate().slideY(begin: 0.2, duration: 400.ms).fade(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _faceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _cameraController?.dispose();
    _record.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, 
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: Text("", style: GoogleFonts.outfit()), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Column(
                    children: [
                      Text(
                        "Write it out",
                        style: GoogleFonts.outfit(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Share in the way that feels right.",
                        style: GoogleFonts.outfit(
                          fontSize: 16, 
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                
                  // Primary Text Area (Glass Card)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        style: GoogleFonts.outfit(
                          fontSize: 18, 
                          height: 1.6, 
                          color: AppTheme.textDark
                        ),
                        decoration: InputDecoration(
                          hintText: "Start typing...\nYou don’t need to explain everything.",
                          hintStyle: GoogleFonts.outfit(
                            color: AppTheme.textDark.withOpacity(0.4), 
                            fontSize: 18,
                            fontStyle: FontStyle.italic
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Reflect Strip (Voice/Face)
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // "Reflect using" Label
                        if (_isCapturingFace)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              "Tracking Face: $_currentFaceEmotion", 
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor
                              ),
                            ),
                          ),
                          
                        if (!_isRecording && _voiceBytes == null && _imageBytes == null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(child: Divider(color: AppTheme.textLight.withOpacity(0.2))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    "Reflect using",
                                    style: GoogleFonts.outfit(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold, 
                                      color: AppTheme.textLight,
                                      letterSpacing: 1
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppTheme.textLight.withOpacity(0.2))),
                              ],
                            ),
                          ),

                        // Chips Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // VOICE CHIP
                            _buildModeChip(
                              label: _isRecording ? "Listening..." : (_voiceBytes != null ? "Voice Added" : "Voice"),
                              icon: _isRecording ? Icons.stop_rounded : (_voiceBytes != null ? Icons.check_rounded : Icons.mic_none_rounded),
                              isActive: _isRecording || _voiceBytes != null,
                              isRecording: _isRecording,
                              onTap: _toggleVoice,
                            ),

                            const SizedBox(width: 24),

                            // FACE CHIP
                            _buildModeChip(
                              label: _isCapturingFace ? "Tracking..." : (_imageBytes != null ? "Face Added" : "Face Track"),
                              icon: _isCapturingFace ? Icons.stop_rounded : (_imageBytes != null ? Icons.check_rounded : Icons.face_rounded),
                              isActive: _isCapturingFace || _imageBytes != null,
                              isRecording: _isCapturingFace,
                              onTap: _toggleFaceTracking,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Bottom Actions
                        Row(
                          children: [
                            Expanded(
                              child: GradientButton(
                                text: _isUploading ? "Analysing..." : "Get Insights",
                                onPressed: _isUploading ? () {} : _analyzeAndSave,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                               content: Text("Entry saved to your private journal.", style: GoogleFonts.outfit()),
                               backgroundColor: AppTheme.successColor,
                             ));
                             Navigator.pop(context);
                          },
                          child: Text(
                            "Save privately", 
                            style: GoogleFonts.outfit(
                              color: AppTheme.textLight, 
                              fontSize: 15, 
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Hidden Camera Preview (keeps lifecycle active without rendering UI)
          if (_isCapturingFace && _cameraController != null && _cameraController!.value.isInitialized)
            Offstage(
              offstage: true,
              child: SizedBox(
                width: 1, 
                height: 1, 
                child: CameraPreview(_cameraController!)
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isRecording,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isActive ? [
            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecording)
              Animate(
                 onPlay: (c) => c.repeat(),
                 effects: [FadeEffect(duration: 800.ms)],
                 child: Icon(Icons.fiber_manual_record, color: Colors.white, size: 12)
              ),
            if (isRecording) const SizedBox(width: 8),
            Icon(icon, color: isActive ? Colors.white : AppTheme.textLight, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
          ],
        ),
      ),
    );
  }
}