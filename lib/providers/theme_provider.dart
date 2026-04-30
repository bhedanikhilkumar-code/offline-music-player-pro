import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:offline_music_player/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  late StorageService _storage;
  Color _primaryColor = AppColors.accentOrange;
  List<Color>? _gradientColors;
  String? _backgroundImagePath;
  bool _isCustomTheme = false;

  Color get primaryColor => _primaryColor;
  List<Color>? get gradientColors => _gradientColors;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isCustomTheme => _isCustomTheme;

  BoxDecoration get backgroundDecoration {
    if (_isCustomTheme && _backgroundImagePath != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(_backgroundImagePath!)),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      );
    }
    
    if (_gradientColors != null && _gradientColors!.length >= 2) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors!,
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.surfaceDark, AppColors.primaryDark],
      ),
    );
  }

  ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: AppColors.primaryDark,
        colorScheme: ColorScheme.dark(
          primary: _primaryColor,
          secondary: _primaryColor,
          surface: AppColors.surfaceDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.bottomSheetBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        dividerColor: AppColors.divider,
        iconTheme: const IconThemeData(color: Colors.white70),
        sliderTheme: SliderThemeData(
          activeTrackColor: _primaryColor,
          thumbColor: _primaryColor,
          inactiveTrackColor: Colors.white24,
          overlayColor: _primaryColor.withOpacity(0.2),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return _primaryColor;
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return _primaryColor.withOpacity(0.5);
            return Colors.grey.withOpacity(0.3);
          }),
        ),
      );

  LinearGradient get playerGradient {
    if (_gradientColors != null && _gradientColors!.length >= 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _gradientColors!,
      );
    }
    return AppColors.playerGradient;
  }

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _primaryColor = Color(_storage.themeColor);
    _isCustomTheme = _storage.isCustomThemeEnabled;
    _backgroundImagePath = _storage.themeBackgroundImagePath;

    final gradientStr = _storage.themeGradient;
    if (gradientStr != null && gradientStr.isNotEmpty) {
      final parts = gradientStr.split(',');
      if (parts.length >= 2) {
        _gradientColors = parts.map((p) => Color(int.parse(p.trim()))).toList();
      }
    }

    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await _storage.setThemeColor(color.value);
    notifyListeners();
  }

  Future<void> setGradient(List<Color> colors) async {
    _gradientColors = colors;
    await _storage.setThemeGradient(colors.map((c) => c.value.toString()).join(','));
    notifyListeners();
  }

  Future<void> setBackgroundImage(String path) async {
    _backgroundImagePath = path;
    _isCustomTheme = true;
    await _storage.setThemeBackgroundImagePath(path);
    await _storage.setIsCustomThemeEnabled(true);
    notifyListeners();
  }

  Future<void> clearCustomTheme() async {
    _backgroundImagePath = null;
    _isCustomTheme = false;
    await _storage.setIsCustomThemeEnabled(false);
    notifyListeners();
  }
}
