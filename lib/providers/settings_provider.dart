import 'package:flutter/material.dart';
import 'package:offline_music_player/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  late StorageService _storage;

  bool _crossfadeEnabled = false;
  bool _gaplessEnabled = true;
  bool _keepScreenOn = false;
  bool _lockScreenPlaying = true;
  bool _pauseOnHeadphoneDetach = true;
  bool _notificationEnabled = true;
  String _selectedLanguage = 'English';
  bool _isPremium = false;
  bool _adsRemoved = false;
  bool _volumeBoosterEnabled = false;
  bool _privacyLockEnabled = false;
  String? _privacyPin;

  bool get crossfadeEnabled => _crossfadeEnabled;
  bool get gaplessEnabled => _gaplessEnabled;
  bool get keepScreenOn => _keepScreenOn;
  bool get lockScreenPlaying => _lockScreenPlaying;
  bool get pauseOnHeadphoneDetach => _pauseOnHeadphoneDetach;
  bool get notificationEnabled => _notificationEnabled;
  String get selectedLanguage => _selectedLanguage;
  bool get isPremium => _isPremium;
  bool get adsRemoved => _adsRemoved;
  bool get volumeBoosterEnabled => _volumeBoosterEnabled;
  bool get privacyLockEnabled => _privacyLockEnabled;
  String? get privacyPin => _privacyPin;

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _crossfadeEnabled = _storage.crossfadeEnabled;
    _gaplessEnabled = _storage.gaplessEnabled;
    _keepScreenOn = _storage.keepScreenOn;
    _lockScreenPlaying = _storage.lockScreenPlaying;
    _pauseOnHeadphoneDetach = _storage.pauseOnHeadphoneDetach;
    _notificationEnabled = _storage.notificationEnabled;
    _selectedLanguage = _storage.selectedLanguage;
    _isPremium = _storage.isPremiumLocal;
    _adsRemoved = _storage.adsRemoved;
    _volumeBoosterEnabled = _storage.volumeBoosterEnabled;
    _privacyLockEnabled = _storage.privacyLockEnabled;
    _privacyPin = _storage.privacyPin;
  }

  Future<void> setCrossfade(bool v) async { _crossfadeEnabled = v; await _storage.setCrossfadeEnabled(v); notifyListeners(); }
  Future<void> setGapless(bool v) async { _gaplessEnabled = v; await _storage.setGaplessEnabled(v); notifyListeners(); }
  Future<void> setKeepScreenOn(bool v) async { _keepScreenOn = v; await _storage.setKeepScreenOn(v); notifyListeners(); }
  Future<void> setLockScreenPlaying(bool v) async { _lockScreenPlaying = v; await _storage.setLockScreenPlaying(v); notifyListeners(); }
  Future<void> setPauseOnDetach(bool v) async { _pauseOnHeadphoneDetach = v; await _storage.setPauseOnHeadphoneDetach(v); notifyListeners(); }
  Future<void> setNotification(bool v) async { _notificationEnabled = v; await _storage.setNotificationEnabled(v); notifyListeners(); }
  Future<void> setLanguage(String v) async { _selectedLanguage = v; await _storage.setSelectedLanguage(v); notifyListeners(); }
  Future<void> setPremium(bool v) async { _isPremium = v; await _storage.setIsPremiumLocal(v); notifyListeners(); }
  Future<void> setAdsRemoved(bool v) async { _adsRemoved = v; await _storage.setAdsRemoved(v); notifyListeners(); }
  Future<void> setVolumeBooster(bool v) async { _volumeBoosterEnabled = v; await _storage.setVolumeBoosterEnabled(v); notifyListeners(); }

  Future<void> setPrivacyLock(bool v) async { _privacyLockEnabled = v; await _storage.setPrivacyLockEnabled(v); notifyListeners(); }
  Future<void> setPrivacyPin(String v) async { _privacyPin = v; await _storage.setPrivacyPin(v); notifyListeners(); }

  String get lastBackupDate => _storage.lastBackupDate ?? 'Never';
  Future<void> updateBackupDate() async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    await _storage.setLastBackupDate(dateStr);
    notifyListeners();
  }
}
