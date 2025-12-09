import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings - Using Orbitron for tech/cyberpunk feel
  static TextStyle h1(bool isDark) => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.getPrimaryColor(isDark),
    letterSpacing: 2,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonCyanGlow,
        blurRadius: 10,
      ),
    ]
        : null,
  );

  static TextStyle h2(bool isDark) => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.getPrimaryColor(isDark),
    letterSpacing: 1.5,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonCyanGlow,
        blurRadius: 8,
      ),
    ]
        : null,
  );

  static TextStyle h3(bool isDark) => GoogleFonts.orbitron(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.getAccentColor(isDark),
    letterSpacing: 1.2,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonPurpleGlow,
        blurRadius: 6,
      ),
    ]
        : null,
  );

  static TextStyle h4(bool isDark) => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextColor(isDark),
    letterSpacing: 1,
  );

  // Body Text - Using Rajdhani for readability with tech aesthetic
  static TextStyle bodyLarge(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextColor(isDark),
    height: 1.5,
  );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextColor(isDark),
    height: 1.5,
  );

  static TextStyle bodySmall(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextColor(isDark),
  );

  // Caption / Subtitle
  static TextStyle caption(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.getSubtextColor(isDark),
    letterSpacing: 0.5,
  );

  static TextStyle subtitle(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.getSubtextColor(isDark),
  );

  // Buttons - Uppercase with heavy weight
  static TextStyle button(bool isDark) => GoogleFonts.orbitron(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: isDark ? Colors.black : Colors.white,
  );

  // Labels - Tech style with letter spacing
  static TextStyle label(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.getTextColor(isDark),
    letterSpacing: 0.5,
  );

  // Username - Bold cyberpunk style
  static TextStyle username(bool isDark) => GoogleFonts.orbitron(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.getPrimaryColor(isDark),
    letterSpacing: 1.5,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonCyanGlow,
        blurRadius: 8,
      ),
    ]
        : null,
  );

  // Timestamp - Monospace tech feel
  static TextStyle timestamp(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.getSubtextColor(isDark),
    letterSpacing: 1,
  );

  // Error messages with neon pink
  static TextStyle error(bool isDark) => GoogleFonts.orbitron(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.error,
    letterSpacing: 1.5,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonPinkGlow,
        blurRadius: 8,
      ),
    ]
        : null,
  );

  // Additional cyberpunk-specific styles

  // System message style (like "LOADING...", "NO POSTS DETECTED")
  static TextStyle systemMessage(bool isDark) => GoogleFonts.orbitron(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.getPrimaryColor(isDark),
    letterSpacing: 3,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonCyanGlow,
        blurRadius: 10,
      ),
    ]
        : null,
  );

  // Navigation label style
  static TextStyle navLabel(bool isDark) => GoogleFonts.orbitron(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    color: AppColors.getPrimaryColor(isDark),
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonCyanGlow,
        blurRadius: 8,
      ),
    ]
        : null,
  );

  // Action button text (for like/comment counts)
  static TextStyle actionText(bool isDark, {bool isActive = false}) => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: isActive
        ? AppColors.getSecondaryColor(isDark)
        : (isDark ? Colors.white70 : Colors.black54),
    shadows: isActive && isDark
        ? [
      Shadow(
        color: AppColors.neonPinkGlow,
        blurRadius: 8,
      ),
    ]
        : null,
  );

  // Post content text
  static TextStyle postContent(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextColor(isDark),
    height: 1.6,
    letterSpacing: 0.3,
  );

  // Time format text (like "2D AGO")
  static TextStyle timeFormat(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.getSubtextColor(isDark),
    letterSpacing: 1,
  );

  // Success message style
  static TextStyle success(bool isDark) => GoogleFonts.orbitron(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
    letterSpacing: 1.2,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.success.withValues(alpha: 0.5),
        blurRadius: 8,
      ),
    ]
        : null,
  );

  // Warning message style
  static TextStyle warning(bool isDark) => GoogleFonts.orbitron(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.warning,
    letterSpacing: 1.2,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.warning.withValues(alpha: 0.5),
        blurRadius: 8,
      ),
    ]
        : null,
  );

  // Info message style
  static TextStyle info(bool isDark) => GoogleFonts.orbitron(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.info,
    letterSpacing: 1.2,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.info.withValues(alpha: 0.5),
        blurRadius: 8,
      ),
    ]
        : null,
  );

  // Input field text
  static TextStyle input(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextColor(isDark),
    letterSpacing: 0.5,
  );

  // Input hint text
  static TextStyle inputHint(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.getSubtextColor(isDark),
    letterSpacing: 0.5,
  );

  // Link text style
  static TextStyle link(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.getPrimaryColor(isDark),
    decoration: TextDecoration.underline,
    decorationColor: AppColors.getPrimaryColor(isDark),
  );

  // Badge/Chip text
  static TextStyle badge(bool isDark) => GoogleFonts.orbitron(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: isDark ? Colors.black : Colors.white,
    letterSpacing: 1.5,
  );

  // Large system title (for empty states, errors)
  static TextStyle systemTitle(bool isDark) => GoogleFonts.orbitron(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.getPrimaryColor(isDark),
    letterSpacing: 2,
    shadows: isDark
        ? [
      Shadow(
        color: AppColors.neonCyanGlow,
        blurRadius: 10,
      ),
    ]
        : null,
  );

  // Secondary system message (for descriptions under titles)
  static TextStyle systemSubtitle(bool isDark) => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.getSubtextColor(isDark),
  );

  // Monospace text for codes/technical info
  static TextStyle monospace(bool isDark) => GoogleFonts.sourceCodePro(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextColor(isDark),
    letterSpacing: 0.5,
  );
}
