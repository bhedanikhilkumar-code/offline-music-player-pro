import 'package:flutter/material.dart';

class AppColors {
  // Primary dark theme colors (matching reference screenshots)
  static const Color primaryDark = Color(0xFF0D0B1E);
  static const Color surfaceDark = Color(0xFF151327);
  static const Color cardDark = Color(0xFF1E1B35);
  static const Color cardDarkLight = Color(0xFF252344);

  // Accent colors
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color accentAmber = Color(0xFFFFAB00);
  static const Color accentPink = Color(0xFFFF4081);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentBlue = Color(0xFF448AFF);

  // Player gradient colors
  static const Color playerGradientStart = Color(0xFFE91E63);
  static const Color playerGradientMid = Color(0xFF9C27B0);
  static const Color playerGradientEnd = Color(0xFF3F51B5);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);

  // Drawer gradient
  static const Color drawerStart = Color(0xFF1A1040);
  static const Color drawerEnd = Color(0xFF0D0B1E);

  // Bottom sheet
  static const Color bottomSheetBg = Color(0xFF1C1C2E);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);

  // Divider
  static const Color divider = Color(0xFF2A2A3E);

  // Available theme colors for skin screen
  static const List<Color> themeColors = [
    Color(0xFFFF8C00), // Orange (default)
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFFFF4081), // Pink Accent
    Color(0xFF7C4DFF), // Deep Purple Accent
    Color(0xFF448AFF), // Blue Accent
    Color(0xFF18FFFF), // Cyan Accent
    Color(0xFF69F0AE), // Green Accent
    Color(0xFFFFD740), // Amber Accent
    Color(0xFFFF6E40), // Deep Orange Accent
  ];

  // Gradient presets
  static const List<List<Color>> gradientPresets = [
    [Color(0xFFE91E63), Color(0xFF3F51B5)],
    [Color(0xFF9C27B0), Color(0xFF00BCD4)],
    [Color(0xFFFF5722), Color(0xFF4CAF50)],
    [Color(0xFF2196F3), Color(0xFFE91E63)],
    [Color(0xFF673AB7), Color(0xFFFF9800)],
    [Color(0xFF00BCD4), Color(0xFF9C27B0)],
    // Unique Themes
    [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)], // Deep Ocean (Glass)
    [Color(0xFF00F260), Color(0xFF0575E6)], // Cyber Neon Green-Blue
    [Color(0xFFFF00CC), Color(0xFF333399)], // Cyber Neon Pink-Blue
    [Color(0xFF434343), Color(0xFF000000)], // Midnight Glass
  ];

  static LinearGradient get playerGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [playerGradientStart, playerGradientMid, playerGradientEnd],
      );

  static LinearGradient get drawerGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [drawerStart, drawerEnd],
      );

  static LinearGradient get splashGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1040), Color(0xFF0D0B1E)],
      );
}
