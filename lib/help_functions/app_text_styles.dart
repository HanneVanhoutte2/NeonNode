import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle h1(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  static TextStyle h2(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  static TextStyle h3(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  static TextStyle h4(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  // Body Text
  static TextStyle bodyLarge(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  static TextStyle bodySmall(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  // Caption / Subtitle
  static TextStyle caption(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
  );

  static TextStyle subtitle(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
  );

  // Buttons
  static TextStyle button(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: isDark ? Colors.black : Colors.white,
  );

  // Labels
  static TextStyle label(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  // Username
  static TextStyle username(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkText : AppColors.lightText,
  );

  // Timestamp
  static TextStyle timestamp(bool isDark) => GoogleFonts.rammettoOne(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
  );

  static TextStyle error() => GoogleFonts.rammettoOne(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );
}
