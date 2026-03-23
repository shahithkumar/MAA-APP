import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MeditationDetailScreen extends StatefulWidget {
  final int id;

  const MeditationDetailScreen({super.key, required this.id});

  @override
  State<MeditationDetailScreen> createState() => _MeditationDetailScreenState();
}

class _MeditationDetailScreenState extends State<MeditationDetailScreen> {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _bgmPlaying = false;
  bool _musicOn = true;
  Map<String, dynamic>? _meditation;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchMeditation();
    _setupAudio();
  }

  void _setupAudio() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((Duration p) {
      if (mounted) setState(() => _position = p);
    });
    _bgmPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) setState(() => _bgmPlaying = state == PlayerState.playing);
    });
  }

  Future<void> _fetchMeditation() async {
    try {
      final data = await _apiService.getMeditationDetail(widget.id);
      if (mounted) setState(() => _meditation = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load meditation: $e')));
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleMainAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else if (_meditation?['audio_file'] != null) {
        String path = _meditation!['audio_file'] as String;
        final String fullUrl = path.startsWith('http') ? path : '${_apiService.baseUrl}$path';
        print('🔊 DEBUG: Playing Audio from: $fullUrl');
        await _audioPlayer.play(UrlSource(fullUrl));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE0F7FA), // Light Cyan
              const Color(0xFFE1BEE7), // Soft Lavender
              const Color(0xFFF3E5F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _meditation == null
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildArtwork(),
                        const SizedBox(height: 40),
                        _buildTrackInfo(),
                        const SizedBox(height: 40),
                        _buildProgressBar(),
                        const SizedBox(height: 40),
                        _buildControls(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'MEDITATION SESSION',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppTheme.textDark.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _meditation!['title'] ?? 'Untitled',
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildArtwork() {
    return Container(
      height: 260,
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 10,
          )
        ],
      ),
      child: Center(
        child: Text(
          _meditation!['emoji'] ?? '🧘',
          style: const TextStyle(fontSize: 100),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .scale(duration: 4000.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), curve: Curves.easeInOut),
    );
  }

  Widget _buildTrackInfo() {
    return Column(
      children: [
        Text(
          _meditation!['description'] ?? '',
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: Colors.white.withOpacity(0.5),
            thumbColor: AppTheme.primaryColor,
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 100.0,
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await _audioPlayer.seek(position);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position), style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
              Text(_formatDuration(_duration), style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, size: 32),
          onPressed: () {},
          color: AppTheme.textDark.withOpacity(0.7),
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: _toggleMainAudio,
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        const SizedBox(width: 32),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 32),
          onPressed: () {},
          color: AppTheme.textDark.withOpacity(0.7),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
