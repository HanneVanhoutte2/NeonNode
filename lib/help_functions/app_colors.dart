import 'package:flutter/material.dart';

class AppColors {
  // Cyberpunk Dark Mode - Neon Colors
  static const primary = Color(0xFF00F0FF);           // Neon Cyan
  static const secondary = Color(0xFFFF006E);         // Neon Pink
  static const accent = Color(0xFFB026FF);            // Neon Purple
  static const accentSecondary = Color(0xFFFFF01F);   // Neon Yellow

  // Cyberpunk Light Mode - Pastel Colors
  static const primaryDark = Color(0xFF00B0FF);       // Dark Cyan
  static const secondaryDark = Color(0xFFFF006E);     // Dark Pink
  static const accentDark = Color(0xFF4100FF);        // Dark Purple
  static const accentSecondaryDark = Color(0xFFF6D300); // Dark Yellow

  // Dark Theme Background Colors
  static const darkBackground = Color(0xFF0A0E27);
  static const darkBackgroundGradient = Color(0xFF050816);
  static const darkCard = Color(0xFF1A1F3A);
  static const darkBorder = Color(0xFF00F0FF);
  static const darkText = Colors.white;
  static const darkSubtext = Color(0xFFB0B0B0);

  // Light Theme Background Colors
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFA78BFA);
  static const lightText = Color(0xFF1A1A1A);
  static const lightSubtext = Color(0xFF6B7280);

  // Status Colors - Cyberpunk themed
  static const success = Color(0xFF10B981);           // Neon Green
  static const warning = Color(0xFFFBBF24);           // Bright Yellow
  static const info = Color(0xFF3B82F6);              // Electric Blue
  static const error = Color(0xFFFF006E);             // Neon Pink (matching secondary)

  // Glow effect colors (for shadows/neon effects)
  static Color neonCyanGlow = const Color(0xFF00F0FF).withValues(alpha: 0.5);
  static Color neonPinkGlow = const Color(0xFFFF006E).withValues(alpha: 0.5);
  static Color neonPurpleGlow = const Color(0xFFB026FF).withValues(alpha: 0.5);
  static Color neonYellowGlow = const Color(0xFFFFF01F).withValues(alpha: 0.5);

  // Grid/Wireframe colors
  static Color gridDark = const Color(0xFF00F0FF).withValues(alpha: 0.1);
  static Color gridLight = const Color(0xFFA78BFA).withValues(alpha: 0.15);

  // Interactive states (dark mode)
  static Color hoverDark = const Color(0xFF00F0FF).withValues(alpha: 0.2);
  static Color activeDark = const Color(0xFF00F0FF).withValues(alpha: 0.3);
  static Color disabledDark = const Color(0xFFFFFFFF).withValues(alpha: 0.3);

  // Interactive states (light mode)
  static Color hoverLight = const Color(0xFFA78BFA).withValues(alpha: 0.15);
  static Color activeLight = const Color(0xFFA78BFA).withValues(alpha: 0.25);
  static Color disabledLight = const Color(0xFF1A1A1A).withValues(alpha: 0.3);

  // Gradient helpers
  static LinearGradient darkGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E27),
      Color(0xFF050816),
      Color(0xFF0A0E27),
    ],
  );

  static LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFFAFAFA),
      const Color(0xFFA78BFA).withValues(alpha: 0.05),
      const Color(0xFF7DD3FC).withValues(alpha: 0.05),
    ],
  );

  static LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF00F0FF).withValues(alpha: 0.2),
      const Color(0xFFB026FF).withValues(alpha: 0.2),
    ],
  );

  static LinearGradient cardGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFA78BFA).withValues(alpha: 0.15),
      const Color(0xFF7DD3FC).withValues(alpha: 0.15),
    ],
  );

  static LinearGradient avatarGradientDark = const LinearGradient(
    colors: [
      Color(0xFF00F0FF),
      Color(0xFFB026FF),
    ],
  );

  static LinearGradient avatarGradientLight = const LinearGradient(
    colors: [
      Color(0xFFA78BFA),
      Color(0xFF7DD3FC),
    ],
  );

  // Corner accent colors (for the bracket decorations)
  static const cornerAccent1 = Color(0xFF00F0FF);     // Cyan
  static const cornerAccent2 = Color(0xFFFF006E);     // Pink
  static const cornerAccent3 = Color(0xFFB026FF);     // Purple
  static const cornerAccent4 = Color(0xFFFFF01F);     // Yellow

  // Light mode corner accents
  static const cornerAccent1Light = Color(0xFF7DD3FC);
  static const cornerAccent2Light = Color(0xFFF472B6);
  static const cornerAccent3Light = Color(0xFFA78BFA);
  static const cornerAccent4Light = Color(0xFFFDE047);

  // Helper methods
  static Color getPrimaryColor(bool isDark) => isDark ? primary : primaryDark;
  static Color getSecondaryColor(bool isDark) => isDark ? secondary : secondaryDark;
  static Color getAccentColor(bool isDark) => isDark ? accent : accentDark;
  static Color getBackgroundColor(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color getCardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color getTextColor(bool isDark) => isDark ? darkText : lightText;
  static Color getSubtextColor(bool isDark) => isDark ? darkSubtext : lightSubtext;
  static Color getBorderColor(bool isDark) => isDark ? darkBorder : lightBorder;

  static LinearGradient getBackgroundGradient(bool isDark) =>
      isDark ? darkGradient : lightGradient;

  static LinearGradient getCardGradient(bool isDark) =>
      isDark ? cardGradientDark : cardGradientLight;

  static LinearGradient getAvatarGradient(bool isDark) =>
      isDark ? avatarGradientDark : avatarGradientLight;
}
