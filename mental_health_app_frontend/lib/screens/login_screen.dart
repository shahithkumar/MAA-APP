import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'dashboard_screen.dart';
import 'reset_password_confirm_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _apiService.login(_emailController.text, _passwordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showServerSettings() {
    final ipController = TextEditingController(text: _apiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.settings, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text('Server Settings'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter backend URL'),
            const SizedBox(height: 10),
            CustomTextField(
              controller: ipController,
              hintText: 'http://10.123.238.189:8000',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _apiService.updateBaseUrl(ipController.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server updated to: ${_apiService.baseUrl}')),
                );
              }
            },
            child: Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _apiService.loadBaseUrl();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 🌸 Background Decoration
          Positioned(
            top: -100,
            left: -50,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/abstract_shapes.png', 
                width: 400,
                color: AppTheme.primaryColor.withOpacity(0.1),
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.settings, color: AppTheme.primaryColor.withOpacity(0.5)),
                          onPressed: _showServerSettings,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // 🖼️ Welcome Illustration
                      Center(
                        child: Image.asset(
                          'assets/images/welcome_illustration.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Header
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit( // Mellow Font
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Sign in to your safe space',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? 'Password is required' : null,
                      ),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.outfit(color: AppTheme.primaryColor.withOpacity(0.8)),
                          ),
                        ),
                      ),

                      // Error Message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.outfit(color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Submit Button
                      GradientButton(
                        text: 'Login',
                        onPressed: _login,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Signup Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.outfit(color: AppTheme.textLight),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            ),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.outfit(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      // Temporary Manual Reset Link (kept from original)
                      TextButton(
                         onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordConfirmScreen(
                              uid: '5', 
                              token: 'cxksoj-2b57ede39ea28f41f80d38c144569bee', 
                            ),
                          ),
                        ),
                        child: Text(
                          'Reset Password (Manual Debug)',
                          style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}