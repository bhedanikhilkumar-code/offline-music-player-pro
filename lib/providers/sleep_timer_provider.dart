import 'dart:async';
import 'package:flutter/material.dart';
import 'package:offline_music_player/services/storage_service.dart';

class SleepTimerProvider extends ChangeNotifier {
  StorageService? _storage;
  Timer? _timer;
  DateTime? _endTime;
  bool _isRunning = false;
  int _remainingSeconds = 0;
  VoidCallback? _onTimerEnd;
  bool _initialized = false;

  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;
  int get remainingMinutes => (_remainingSeconds / 60).ceil();
  DateTime? get endTime => _endTime;

  String get remainingFormatted {
    final h = _remainingSeconds ~/ 3600;
    final m = ((_remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _initialized = true;
  }

  void setOnTimerEnd(VoidCallback callback) {
    _onTimerEnd = callback;
  }

  void startTimer(int minutes, {int seconds = 0}) {
    cancelTimer();
    final totalSeconds = (minutes * 60) + seconds;
    _endTime = DateTime.now().add(Duration(seconds: totalSeconds));
    _remainingSeconds = totalSeconds;
    _isRunning = true;
    if (_initialized) {
      _storage?.setSleepTimerEnabled(true);
      _storage?.setSleepTimerMinutes(minutes);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _onTimerEnd?.call();
        cancelTimer();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _remainingSeconds = 0;
    _endTime = null;
    if (_initialized) {
      _storage?.setSleepTimerEnabled(false);
    }
    notifyListeners();
  }
}
