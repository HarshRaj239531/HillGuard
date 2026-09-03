import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Safety Palette
  static const Color background = Color(0xFF080C14);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF1F2937);
  static const Color surfaceGlass = Color(0xDD161F30);

  static const Color primary = Color(0xFF00E5FF); // Electric Cyan
  static const Color primaryDark = Color(0xFF0091EA);
  static const Color accentTeal = Color(0xFF00BFA5); // Hill Safety Teal

  // Hazard Severity Colors
  static const Color severityLow = Color(0xFF10B981); // Emerald
  static const Color severityMedium = Color(0xFFF59E0B); // Amber
  static const Color severityHigh = Color(0xFFF97316); // Orange-Red
  static const Color severityCritical = Color(0xFFEF4444); // Neon Crimson

  // Mesh & Offline Indicators
  static const Color meshActive = Color(0xFF8B5CF6); // Purple
  static const Color meshRelay = Color(0xFF3B82F6); // Blue
  static const Color offlineWarning = Color(0xFFEAB308);

  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color borderSubtle = Color(0xFF374151);
  static const Color borderFocus = Color(0xFF00E5FF);

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentTeal,
        surface: surface,
        error: severityCritical,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black.withAlpha(128),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
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
          borderSide: const BorderSide(color: borderFocus, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 3,
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
    );
  }
}
