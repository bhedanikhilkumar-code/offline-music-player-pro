import 'package:flutter/material.dart';
import '../models/equalizer_model.dart';
import 'package:offline_music_player/services/storage_service.dart';
import '../services/equalizer_service.dart';
import '../constants/app_constants.dart';

class EqualizerProvider extends ChangeNotifier {
  late StorageService _storage;
  final EqualizerService _eqService = EqualizerService();
  EqualizerModel _model = EqualizerModel.defaultEq;

  EqualizerModel get model => _model;
  bool get enabled => _model.enabled;
  String get preset => _model.presetName;
  List<double> get bandLevels => _model.bandLevels;
  double get bassBoost => _model.bassBoost;
  double get virtualizer => _model.virtualizer;

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _model = EqualizerModel(
      presetName: _storage.equalizerPreset,
      bandLevels: _storage.eqBandValues,
      bassBoost: _storage.bassBoostLevel,
      virtualizer: _storage.virtualizerLevel,
      enabled: _storage.equalizerEnabled,
    );
    _applyToService();
  }

  void _applyToService() {
    _eqService.setEnabled(_model.enabled);
    _eqService.setPreset(_model.presetName);
    _eqService.setBandLevels(_model.bandLevels);
    _eqService.setBassBoost(_model.bassBoost);
    _eqService.setVirtualizer(_model.virtualizer);
  }

  Future<void> setEnabled(bool value) async {
    _model = _model.copyWith(enabled: value);
    await _storage.setEqualizerEnabled(value);
    _applyToService();
    notifyListeners();
  }

  Future<void> setPreset(String name) async {
    final bands = AppConstants.eqPresets[name] ?? [0, 0, 0, 0, 0];
    _model = _model.copyWith(presetName: name, bandLevels: bands);
    await _storage.setEqualizerPreset(name);
    await _storage.setEqBandValues(bands);
    _applyToService();
    notifyListeners();
  }

  Future<void> setBandLevel(int index, double level) async {
    final bands = List<double>.from(_model.bandLevels);
    bands[index] = level;
    _model = _model.copyWith(presetName: 'Custom', bandLevels: bands);
    await _storage.setEqualizerPreset('Custom');
    await _storage.setEqBandValues(bands);
    _applyToService();
    notifyListeners();
  }

  Future<void> setBassBoost(double level) async {
    _model = _model.copyWith(bassBoost: level);
    await _storage.setBassBoostLevel(level);
    _applyToService();
    notifyListeners();
  }

  Future<void> setVirtualizer(double level) async {
    _model = _model.copyWith(virtualizer: level);
    await _storage.setVirtualizerLevel(level);
    _applyToService();
    notifyListeners();
  }
}
