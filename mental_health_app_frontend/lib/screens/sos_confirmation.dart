import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class SOSConfirmationScreen extends StatefulWidget {
  final String guardianName;

  const SOSConfirmationScreen({super.key, required this.guardianName});

  @override
  _SOSConfirmationScreenState createState() => _SOSConfirmationScreenState();
}

class _SOSConfirmationScreenState extends State<SOSConfirmationScreen> {
  final player = AudioPlayer();
  bool _canCancel = true;

  @override
  void initState() {
    super.initState();
    _playAlarm();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _canCancel = false;
        });
      }
    });
  }

  Future<void> _playAlarm() async {
    try {
      // Use a reliable online source for the alarm sound since local assets are not set up
      await player.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  Future<void> _callGuardian(BuildContext context) async {
    try {
      final guardian = await ApiService().getGuardian();
      if (guardian == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardian not found')));
        return;
      }
      final phone = guardian['phone_number'];
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to make call')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _shareLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled')));
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final locationUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
        final guardian = await ApiService().getGuardian();
        if (guardian == null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardian not found')));
          return;
        }
        final phone = guardian['phone_number'];
        final uri = Uri.parse('sms:$phone?body=My current location: $locationUrl');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to send SMS')));
          }
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
          
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing location: $e')));
      }
    }
  }

  Future<void> _cancelAlert(BuildContext context) async {
    if (!_canCancel) return;
    HapticFeedback.heavyImpact();
    // if (!kIsWeb && await Vibrate.canVibrate) {
    //   Vibrate.feedback(FeedbackType.warning);
    // }
    player.stop();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEF9A9A), Color(0xFFFFCDD2)], // Soft Red Gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Pulse Animation
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 30, spreadRadius: 10)
                    ]
                  ),
                  child: Icon(Icons.mark_email_read_rounded, size: 64, color: Colors.teal.shade700),
                ),
                const SizedBox(height: 40),
                
                GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Text(
                        'Alert Sent',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your SOS alert has been sent to ${widget.guardianName}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Help is on the way. Stay where you are.',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppTheme.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                GradientButton(
                  text: 'Call Guardian Now',
                  icon: Icons.phone_rounded,
                  onPressed: () => _callGuardian(context),
                  colors: const [Colors.teal, Colors.tealAccent],
                ),
                
                const SizedBox(height: 16),
                
                GradientButton(
                  text: 'Share Live Location',
                  icon: Icons.location_on_rounded,
                  onPressed: () => _shareLocation(context),
                  colors: const [Colors.blue, Colors.lightBlueAccent],
                ),
                
                const SizedBox(height: 40),
                
                if (_canCancel)
                  TextButton.icon(
                    onPressed: () => _cancelAlert(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    label: Text(
                      'Cancel Alert (if accidental)',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Alert Active - Cannot Cancel",
                      style: GoogleFonts.outfit(color: Colors.red.shade900, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}