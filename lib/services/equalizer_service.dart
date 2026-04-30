import 'dart:io';
import 'package:flutter/services.dart';

class EqualizerService {
  static final EqualizerService _instance = EqualizerService._();
  factory EqualizerService() => _instance;
  EqualizerService._();

  static const _channel = MethodChannel('com.musicplayer.equalizer');

  bool _initialized = false;
  bool _enabled = false;
  String _preset = 'Normal';
  List<double> _bandLevels = [0, 0, 0, 0, 0];
  double _bassBoost = 0;
  double _virtualizer = 0;
  int _reverbPreset = 0;
  int _audioSessionId = 0;

  bool get enabled => _enabled;
  bool get initialized => _initialized;
  String get preset => _preset;
  List<double> get bandLevels => List.from(_bandLevels);
  double get bassBoost => _bassBoost;
  double get virtualizer => _virtualizer;
  int get reverbPreset => _reverbPreset;

  /// Initialize with the audio session ID from just_audio player
  Future<void> init(int audioSessionId) async {
    if (!Platform.isAndroid) return;
    _audioSessionId = audioSessionId;
    try {
      await _channel.invokeMethod('init', {'sessionId': audioSessionId});
      _initialized = true;
    } catch (e) {
      // Platform channel not available — EQ will work in UI-only mode
      _initialized = false;
    }
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (_initialized && Platform.isAndroid) {
      try {
        _channel.invokeMethod('setEnabled', {'enabled': value});
      } catch (_) {}
    }
  }

  void setPreset(String name) {
    _preset = name;
  }

  void setBandLevels(List<double> levels) {
    _bandLevels = List.from(levels);
    if (_initialized && Platform.isAndroid && _enabled) {
      for (int i = 0; i < levels.length; i++) {
        setBandLevel(i, levels[i]);
      }
    }
  }

  void setBandLevel(int index, double level) {
    if (index >= 0 && index < _bandLevels.length) {
      _bandLevels[index] = level;
      if (_initialized && Platform.isAndroid && _enabled) {
        try {
          // Convert from dB (-15 to 15) to millibels (-1500 to 1500)
          final millibels = (level * 100).toInt();
          _channel.invokeMethod('setBandLevel', {'band': index, 'level': millibels});
        } catch (_) {}
      }
    }
  }

  void setBassBoost(double level) {
    _bassBoost = level;
    if (_initialized && Platform.isAndroid && _enabled) {
      try {
        // level is 0-1000 strength
        _channel.invokeMethod('setBassBoost', {'strength': level.toInt()});
      } catch (_) {}
    }
  }

  void setVirtualizer(double level) {
    _virtualizer = level;
    if (_initialized && Platform.isAndroid && _enabled) {
      try {
        // level is 0-1000 strength
        _channel.invokeMethod('setVirtualizer', {'strength': level.toInt()});
      } catch (_) {}
    }
  }

  void setReverb(int preset) {
    _reverbPreset = preset;
    if (_initialized && Platform.isAndroid && _enabled) {
      try {
        _channel.invokeMethod('setReverb', {'preset': preset});
      } catch (_) {}
    }
  }

  void dispose() {
    if (_initialized && Platform.isAndroid) {
      try {
        _channel.invokeMethod('release');
      } catch (_) {}
    }
    _initialized = false;
  }
}
