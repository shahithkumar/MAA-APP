import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 COLORS (Mellow-Inspired Palette)
  static const Color primaryColor = Color(0xFF2D3142); // Deep Navy Blue (Text/Headers)
  static const Color primaryDark = Color(0xFF1F222E); // Darker Navy
  static const Color accentColor = Color(0xFFF8E192); // Mellow Yellow (Highlights)
  
  // Custom Pastel Palette for Cards/Backgrounds
  static const Color mellowYellow = Color(0xFFFFF5D1); // Soft Yellow
  static const Color mintGreen = Color(0xFFCFF6E3);    // Soft Mint
  static const Color softPurple = Color(0xFFE0CFFC);   // Soft Purple
  static const Color softPink = Color(0xFFFFD1D1);     // Soft Pink
  
  static const Color backgroundColor = Colors.white; // Clean White Background
  static const Color surfaceColor = Color(0xFFF8F9FA); // Very light grey surface
  
  static const Color textDark = Color(0xFF2D3142); // Navy for main text
  static const Color textLight = Color(0xFF9098B1); // Grey for subtitles
  static const Color errorColor = Color(0xFFFF5252);
  static const Color successColor = Color(0xFF4CAF50);

  // Gradient for Primary Buttons/Headers (Subtle Navy)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D3142), Color(0xFF4A506B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 📐 SHAPES (Bubbly/Rounded)
  static const double cardRadius = 32.0;    // Increased for bubbly look
  static const double buttonRadius = 32.0;  // Fully rounded buttons
  static const double inputRadius = 24.0;   // Rounded inputs

  // 🖋️ TYPOGRAPHY
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      brightness: Brightness.light,
      
      // Font Family
      fontFamily: GoogleFonts.outfit().fontFamily,
      fontFamilyFallback: const ['Segoe UI Emoji', 'Apple Color Emoji', 'Noto Color Emoji'],
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textLight),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
