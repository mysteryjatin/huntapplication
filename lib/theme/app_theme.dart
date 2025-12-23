import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF8B5CF6); // purple brand color
  static const Color primaryColor = Color(0xFF2FED9A); // brand color (keeping for backward compatibility)
  static const Color textDark = Color(0xFF202124);
  static const Color textLight = Color(0xFF6B7280);
  static const Color background = Colors.white;
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color subtitlecolor = Color(0xFF929292);
  static const Color redcolor = Color(0xFFEF1D1D);
  static const Color cardbg = Color(0xFFF2F9FF);
  static const cardBg = Color(0xFFF5F7FA);
  static const inputBg = Colors.white;
  static const lightBorder = Color(0xFFE8EEF1);
  static const primary = Color(0xFF2FED9A); // provided
  static const lightBlueCard = Color(0xFFEDF8FB);
  static const textGray = Color(0xFF7A7A7A);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      labelSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(48),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}




