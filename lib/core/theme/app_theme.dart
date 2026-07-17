import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constanst/agri_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AgriColors.background,
      primaryColor: AgriColors.primary,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.dmSans(textStyle: const TextStyle(color: AgriColors.textDark, fontSize: 16)),
        bodyMedium: GoogleFonts.dmSans(textStyle: const TextStyle(color: AgriColors.textDark, fontSize: 14)),
      ),
      colorScheme: ColorScheme.light(
        primary: AgriColors.primary,
        secondary: AgriColors.accent,
        surface: AgriColors.background,
        error: AgriColors.danger,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: AgriColors.primary,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.dmSans(textStyle: const TextStyle(color: Colors.white, fontSize: 16)),
        bodyMedium: GoogleFonts.dmSans(textStyle: const TextStyle(color: Colors.white70, fontSize: 14)),
      ),
      colorScheme: ColorScheme.dark(
        primary: AgriColors.primary,
        secondary: AgriColors.accent,
        surface: const Color(0xFF1E1E1E),
        error: AgriColors.danger,
      ),
    );
  }
}
