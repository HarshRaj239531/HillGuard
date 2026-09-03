import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==========================================
  // Light Palette (Modern Crisp Alpine HUD)
  // ==========================================
  static const Color background = Color(0xFFF8FAFC); // Clean Slate 50
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceElevated = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceGlass = Color(0xF2FFFFFF); // Frosted White

  // Primary & Accent Brand Tokens
  static const Color primary = Color(0xFF0284C7); // Deep Sky Cobalt
  static const Color primaryDark = Color(0xFF0369A1);
  static const Color accentTeal = Color(0xFF0D9488); // Mountain Forest Teal

  // Hazard Severity Colors (Calibrated for High Daylight Legibility)
  static const Color severityLow = Color(0xFF059669); // Emerald
  static const Color severityMedium = Color(0xFFD97706); // Amber
  static const Color severityHigh = Color(0xFFEA580C); // Orange-Red
  static const Color severityCritical = Color(0xFFDC2626); // Crimson Danger

  // Mesh & Offline Indicators
  static const Color meshActive = Color(0xFF7C3AED); // Royal Violet
  static const Color meshRelay = Color(0xFF2563EB); // Vivid Blue
  static const Color offlineWarning = Color(0xFFB45309);

  // Typography Tokens
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Border Tokens
  static const Color borderSubtle = Color(0xFFE2E8F0); // Slate 200
  static const Color borderFocus = Color(0xFF0284C7);

  // ==========================================
  // Premium Light Theme
  // ==========================================
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accentTeal,
        surface: surface,
        error: severityCritical,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.6,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1.2),
        ),
        shadowColor: const Color(0x0A000000),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderFocus, width: 1.8),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primary.withAlpha(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderSubtle),
        ),
        labelStyle: const TextStyle(fontSize: 12, color: textPrimary),
      ),
    );
  }

  // Soft Tint Helper for Emergency Badges in Light Mode
  static Color severityBackground(Color severityColor) {
    return severityColor.withAlpha(25);
  }
}
