import 'package:flutter/material.dart';
import 'package:offline_music_player/services/storage_service.dart';

class LyricsProvider extends ChangeNotifier {
  StorageService? _storage;

  Future<void> init(StorageService storage) async {
    _storage = storage;
  }

  String? getLyrics(int songId) => _storage?.getLyrics(songId);

  Future<void> saveLyrics(int songId, String lyrics) async {
    await _storage?.saveLyrics(songId, lyrics);
    notifyListeners();
  }

  bool hasLyrics(int songId) => _storage?.getLyrics(songId) != null;
}
