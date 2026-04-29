import 'package:flutter/material.dart';
import '../models/equalizer_model.dart';
import 'package:offline_music_player/services/storage_service.dart';
import '../services/equalizer_service.dart';
import '../constants/app_constants.dart';

class EqualizerProvider extends ChangeNotifier {
  late StorageService _storage;
  final EqualizerService _eqService = EqualizerService();
  EqualizerModel _model = EqualizerModel.defaultEq;
  int _lastSessionId = 0;

  EqualizerModel get model => _model;
  bool get enabled => _model.enabled;
  String get preset => _model.presetName;
  List<double> get bandLevels => _model.bandLevels;
  double get bassBoost => _model.bassBoost;
  double get virtualizer => _model.virtualizer;
  bool get isInitialized => _eqService.initialized;

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _model = EqualizerModel(
      presetName: _storage.equalizerPreset,
      bandLevels: _storage.eqBandValues,
      bassBoost: _storage.bassBoostLevel,
      virtualizer: _storage.virtualizerLevel,
      enabled: _storage.equalizerEnabled,
    );
    notifyListeners();
  }

  /// Initialize the native equalizer with the audio session ID
  /// Call this after audio playback starts and the session ID is available
  Future<void> initWithAudioSession(int audioSessionId) async {
    if (audioSessionId <= 0 || audioSessionId == _lastSessionId) return;
    _lastSessionId = audioSessionId;

    await _eqService.init(audioSessionId);
    _applyAllSettings();
    notifyListeners();
  }

  void _applyAllSettings() {
    _eqService.setEnabled(_model.enabled);
    _eqService.setBandLevels(_model.bandLevels);
    _eqService.setBassBoost(_model.bassBoost);
    _eqService.setVirtualizer(_model.virtualizer);
  }

  Future<void> setEnabled(bool value) async {
    _model = _model.copyWith(enabled: value);
    await _storage.setEqualizerEnabled(value);
    _eqService.setEnabled(value);
    if (value) {
      // Re-apply all settings when enabling
      _eqService.setBandLevels(_model.bandLevels);
      _eqService.setBassBoost(_model.bassBoost);
      _eqService.setVirtualizer(_model.virtualizer);
    }
    notifyListeners();
  }

  Future<void> setPreset(String name) async {
    final bands = AppConstants.eqPresets[name] ?? [0, 0, 0, 0, 0];
    _model = _model.copyWith(presetName: name, bandLevels: bands);
    await _storage.setEqualizerPreset(name);
    await _storage.setEqBandValues(bands);
    _eqService.setBandLevels(bands);
    notifyListeners();
  }

  Future<void> setBandLevel(int index, double level) async {
    final bands = List<double>.from(_model.bandLevels);
    bands[index] = level;
    _model = _model.copyWith(presetName: 'Custom', bandLevels: bands);
    await _storage.setEqualizerPreset('Custom');
    await _storage.setEqBandValues(bands);
    _eqService.setBandLevel(index, level);
    notifyListeners();
  }

  Future<void> setBassBoost(double level) async {
    _model = _model.copyWith(bassBoost: level);
    await _storage.setBassBoostLevel(level);
    _eqService.setBassBoost(level);
    notifyListeners();
  }

  Future<void> setVirtualizer(double level) async {
    _model = _model.copyWith(virtualizer: level);
    await _storage.setVirtualizerLevel(level);
    _eqService.setVirtualizer(level);
    notifyListeners();
  }
}
