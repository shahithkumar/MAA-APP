import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _guardian;
  bool _isLoading = true;
  bool _isEditing = false; // New flag for read-only mode
  String? _errorMessage;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGuardian();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchGuardian() async {
    try {
      final guardian = await _apiService.getGuardian();
      if (mounted) {
        setState(() {
          _guardian = guardian;
          _nameController.text = guardian?['name'] ?? '';
          _relationshipController.text = guardian?['relationship'] ?? '';
          _phoneController.text = guardian?['phone_number'] ?? '';
          _emailController.text = guardian?['email'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load guardian: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateGuardian() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _apiService.updateGuardian(
        name: _nameController.text,
        relationship: _relationshipController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardian updated successfully')),
        );
        _fetchGuardian();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update guardian: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppTheme.textLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: GoogleFonts.outfit(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e'), backgroundColor: AppTheme.errorColor),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profile & Safety', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 🛑 Header with Zen Circle Art
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile_header.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                     borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.softPurple,
                          backgroundImage: AssetImage('assets/images/zen_avatar.png'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _guardian?['name'] != null ? 'User' : 'Relax & Breathe', // Placeholder if we don't have user name state separately
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _isLoading && _guardian == null
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : Column(
                      children: [
                         if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(_errorMessage!, style: GoogleFonts.outfit(color: AppTheme.errorColor)),
                            ),

                         Container(
                           padding: const EdgeInsets.all(24),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(32),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.05),
                                 blurRadius: 20,
                                 offset: const Offset(0, 10),
                               ),
                             ],
                           ),
                           child: Form(
                             key: _formKey,
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Row(
                                       children: [
                                         Container(
                                           padding: const EdgeInsets.all(10),
                                           decoration: BoxDecoration(
                                             color: AppTheme.primaryColor.withOpacity(0.1),
                                             shape: BoxShape.circle,
                                           ),
                                           child: const Icon(Icons.shield_rounded, color: AppTheme.primaryColor),
                                         ),
                                         const SizedBox(width: 12),
                                         Text(
                                           'Emergency Contact',
                                           style: GoogleFonts.outfit(
                                             fontSize: 18,
                                             fontWeight: FontWeight.bold,
                                             color: AppTheme.textDark,
                                           ),
                                         ),
                                       ],
                                     ),
                                     IconButton(
                                       onPressed: () => setState(() => _isEditing = !_isEditing),
                                       icon: Icon(
                                         _isEditing ? Icons.close_rounded : Icons.edit_note_rounded,
                                         color: _isEditing ? AppTheme.errorColor : AppTheme.primaryColor,
                                       ),
                                       tooltip: _isEditing ? 'Cancel' : 'Edit Contact',
                                     ),
                                   ],
                                 ),
                                 const SizedBox(height: 24),
                                 CustomTextField(
                                   controller: _nameController,
                                   hintText: 'Guardian Name',
                                   prefixIcon: Icons.person_outline,
                                   enabled: _isEditing,
                                   validator: (value) => value!.isEmpty ? 'Required' : null,
                                 ),
                                 const SizedBox(height: 16),
                                 CustomTextField(
                                   controller: _relationshipController,
                                   hintText: 'Relationship',
                                   prefixIcon: Icons.people_outline,
                                   enabled: _isEditing,
                                   validator: (value) => value!.isEmpty ? 'Required' : null,
                                 ),
                                 const SizedBox(height: 16),
                                 CustomTextField(
                                   controller: _phoneController,
                                   hintText: 'Phone Number',
                                   prefixIcon: Icons.phone_outlined,
                                   keyboardType: TextInputType.phone,
                                   enabled: _isEditing,
                                   validator: (value) => value!.isEmpty ? 'Required' : null,
                                 ),
                                 const SizedBox(height: 16),
                                 CustomTextField(
                                   controller: _emailController,
                                   hintText: 'Email',
                                   prefixIcon: Icons.email_outlined,
                                   keyboardType: TextInputType.emailAddress,
                                   enabled: _isEditing,
                                   validator: (value) {
                                     if (value!.isEmpty) return 'Required';
                                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Invalid email';
                                     return null;
                                   },
                                 ),
                                 const SizedBox(height: 30),
                                 GradientButton(
                                   text: _isEditing ? 'Save Changes' : 'Edit Information',
                                   onPressed: _isEditing ? _updateGuardian : () => setState(() => _isEditing = true),
                                   isLoading: _isLoading,
                                   icon: _isEditing ? Icons.check_circle_outline : Icons.edit_rounded,
                                 ),
                               ],
                             ),
                           ),
                         ),
                         
                         const SizedBox(height: 24),
                         
                         OutlinedButton(
                           onPressed: _logout,
                           style: OutlinedButton.styleFrom(
                             minimumSize: const Size(double.infinity, 56),
                             side: BorderSide(color: AppTheme.errorColor.withOpacity(0.3), width: 1.5),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                             backgroundColor: Colors.white,
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.logout_rounded, color: AppTheme.errorColor, size: 22),
                               const SizedBox(width: 10),
                               Text(
                                 'Logout',
                                 style: GoogleFonts.outfit(
                                   color: AppTheme.errorColor,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         
                         const SizedBox(height: 40),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}