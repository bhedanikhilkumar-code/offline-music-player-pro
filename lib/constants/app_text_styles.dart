import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get _baseStyle => GoogleFonts.poppins();

  // Headings
  static TextStyle get headingLarge => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => _baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get headingSmall => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  // Body
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      );

  // Song tile
  static TextStyle get songTitle => _baseStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get songSubtitle => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white60,
      );

  // Player
  static TextStyle get playerTitle => _baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get playerArtist => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      );

  static TextStyle get playerTime => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      );

  // Tab
  static TextStyle get tabLabel => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  // Button
  static TextStyle get buttonText => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  // Drawer
  static TextStyle get drawerTitle => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get drawerItem => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  // Settings
  static TextStyle get settingsTitle => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get settingsSubtitle => _baseStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.white54,
      );

  // Section header
  static TextStyle get sectionHeader => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white54,
        letterSpacing: 0.5,
      );

  // Mini player
  static TextStyle get miniPlayerTitle => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get miniPlayerArtist => _baseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Colors.white60,
      );
}
