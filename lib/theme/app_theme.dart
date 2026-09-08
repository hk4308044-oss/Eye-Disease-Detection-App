import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Premium Deep Navy & Medical AI Teal
  static const Color primaryNavy = Color(0xFF0F172A);   // Deep Navy / Midnight Slate
  static const Color primaryTeal = Color(0xFF0891B2);   // Medical Teal
  static const Color aiTeal = Color(0xFF06B6D4);        // Bright Cyan AI Accent
  static const Color secondaryNavy = Color(0xFF334155); // Dark Slate Grey
  static const Color lightTeal = Color(0xFFECFEFF);     // Ultra-soft cyan/teal tint
  static const Color softBlue = Color(0xFFE0F2FE);      // Soft sky tint

  // Light Mode Surfaces
  static const Color bgLight = Color(0xFFF8FAFC);       // Soft premium medical grey-white
  static const Color bgSecondary = Color(0xFFF1F5F9);   // Surface background secondary
  static const Color surfaceLight = Color(0xFFFFFFFF);  // Pure white card base
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);   // Clean divider/border

  // Dark Mode Surfaces (Kept for compatibility)
  static const Color bgDark = Color(0xFF070B19); 
  static const Color surfaceDark = Color(0xFF0A1128);
  static const Color cardDark = Color(0xFF111827); 
  static const Color borderDark = Color(0xFF1F2937);

  // Semantic & Status Colors
  static const Color statusGreen = Color(0xFF10B981);  // Success / Low Risk / Active
  static const Color statusYellow = Color(0xFFF59E0B); // Warning / Moderate Risk / Pending
  static const Color statusRed = Color(0xFFEF4444);    // Danger / High Risk / Action Required
  static const Color statusInfo = Color(0xFF06B6D4);   // Information / AI Accent

  // Light Mode Text Colors
  static const Color textLightPrimary = Color(0xFF0F172A);   // High Contrast Heading Text
  static const Color textLightSecondary = Color(0xFF475569); // Muted Body Text
  static const Color textLightDisabled = Color(0xFF94A3B8);  // Disabled/Hint Text

  // Dark Mode Text Colors
  static const Color textDarkPrimary = Color(0xFFF8FAFC); 
  static const Color textDarkSecondary = Color(0xFF94A3B8); 
  static const Color textDarkDisabled = Color(0xFF64748B);

  @Deprecated('Use textLightPrimary instead')
  static const Color textPrimary = textLightPrimary;

  // --- Deprecated Aliases for backward compatibility ---
  @Deprecated('Use primaryNavy instead')
  static const Color darkNavy = primaryNavy;
  @Deprecated('Use aiTeal instead')
  static const Color primaryBlue = aiTeal;
  @Deprecated('Use textLightSecondary instead')
  static const Color textSecondary = textLightSecondary;
  @Deprecated('Use textLightDisabled instead')
  static const Color textDisabled = textLightDisabled;
  @Deprecated('Use bgLight instead')
  static const Color background = bgLight;
  @Deprecated('Use aiTeal instead')
  static const Color techTeal = aiTeal;

  // Modern Soft Shadows
  static List<BoxShadow> get premiumShadowLight => [
        BoxShadow(
          color: primaryNavy.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ];
      
  static List<BoxShadow> get premiumShadowDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  @Deprecated('Use premiumShadowLight or premiumShadowDark instead')
  static List<BoxShadow> get premiumShadow => premiumShadowLight;

  static List<BoxShadow> get subtleShadowLight => [
        BoxShadow(
          color: primaryNavy.withValues(alpha: 0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get subtleShadowDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  @Deprecated('Use subtleShadowLight or subtleShadowDark instead')
  static List<BoxShadow> get subtleShadow => subtleShadowLight;

  // Base Typography System - FORCED INTER EVERYWHERE FOR UNIFIED DESIGN
  static TextTheme _buildTextTheme(TextTheme base, Color primaryColor, Color secondaryColor) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 54, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: -1.0, height: 1.1),
      displayMedium: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: -0.5, height: 1.1),
      displaySmall: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: -0.5, height: 1.2),
      headlineLarge: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: -0.5, height: 1.2),
      headlineMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: -0.4, height: 1.3),
      headlineSmall: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: primaryColor, height: 1.3),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor, height: 1.3),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.15, height: 1.4),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.1, height: 1.4),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: primaryColor, letterSpacing: 0.2, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: secondaryColor, letterSpacing: 0.2, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: secondaryColor, letterSpacing: 0.3, height: 1.3),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.1, height: 1.4),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: secondaryColor, letterSpacing: 0.3, height: 1.3),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: secondaryColor, letterSpacing: 0.3, height: 1.3),
    );
  }

  // --- LIGHT THEME ---
  static ThemeData getLightTheme() {
    final base = ThemeData.light();
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: primaryTeal,
        surface: surfaceLight,
        background: bgLight,
        error: statusRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLightPrimary,
        onBackground: textLightPrimary,
        tertiary: statusGreen, 
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: _buildTextTheme(base.textTheme, textLightPrimary, textLightSecondary),
      useMaterial3: true,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryNavy),
        titleTextStyle: TextStyle(
          color: primaryNavy,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          fontFamily: 'Inter',
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          backgroundColor: Colors.white,
          side: const BorderSide(color: borderLight, width: 1.2),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusRed, width: 1.8),
        ),
        hintStyle: GoogleFonts.inter(color: textLightDisabled, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textLightSecondary, fontSize: 14),
      ),
      
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 24,
      ),
      
      cardTheme: const CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: borderLight, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      
      listTileTheme: const ListTileThemeData(
        textColor: textLightPrimary,
        iconColor: primaryNavy,
      ),
      
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) => 
          states.contains(WidgetState.selected) ? primaryTeal : textLightSecondary
        ),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) => 
          states.contains(WidgetState.selected) ? primaryTeal : Colors.transparent
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: textLightSecondary, width: 1.8),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: bgLight,
        selectedColor: lightTeal,
        labelStyle: GoogleFonts.poppins(color: textLightSecondary, fontWeight: FontWeight.w500, fontSize: 12),
        secondaryLabelStyle: GoogleFonts.poppins(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
        side: const BorderSide(color: borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData getDarkTheme() {
    final base = ThemeData.dark();
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: aiTeal,
        secondary: aiTeal,
        surface: surfaceDark,
        background: bgDark,
        error: statusRed,
        onPrimary: primaryNavy,
        onSecondary: Colors.white,
        onSurface: textDarkPrimary,
        onBackground: textDarkPrimary,
        tertiary: statusGreen,
      ),
      scaffoldBackgroundColor: bgDark,
      textTheme: _buildTextTheme(base.textTheme, textDarkPrimary, textDarkSecondary),
      useMaterial3: true,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          fontFamily: 'Poppins',
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: aiTeal,
          foregroundColor: primaryNavy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: surfaceDark,
          side: const BorderSide(color: borderDark, width: 1.2),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: aiTeal, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusRed, width: 1.8),
        ),
        hintStyle: GoogleFonts.poppins(color: textDarkDisabled, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: textDarkSecondary, fontSize: 14),
      ),
      
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 24,
      ),

      cardTheme: const CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: borderDark, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      
      listTileTheme: const ListTileThemeData(
        textColor: textDarkPrimary,
        iconColor: aiTeal,
      ),
      
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) => 
          states.contains(WidgetState.selected) ? aiTeal : textDarkSecondary
        ),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) => 
          states.contains(WidgetState.selected) ? aiTeal : Colors.transparent
        ),
        checkColor: WidgetStateProperty.all(primaryNavy),
        side: const BorderSide(color: textDarkSecondary, width: 1.8),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: aiTeal.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.poppins(color: textDarkPrimary, fontWeight: FontWeight.w500, fontSize: 12),
        secondaryLabelStyle: GoogleFonts.poppins(color: aiTeal, fontWeight: FontWeight.bold, fontSize: 12),
        side: const BorderSide(color: borderDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
