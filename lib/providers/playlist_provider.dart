import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/playlist_model.dart';
import 'package:offline_music_player/services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  List<PlaylistModel> _playlists = [];
  StorageService? _storage;
  bool _initialized = false;
  final _uuid = const Uuid();

  List<PlaylistModel> get playlists => _playlists;

  Future<void> init(StorageService storage) async {
    if (_initialized) return;
    _storage = storage;
    _loadPlaylists();
    _initialized = true;
  }

  void _loadPlaylists() {
    if (_storage == null) return;
    _playlists = PlaylistModel.decodeList(_storage!.playlistsJson);
    notifyListeners();
  }

  Future<void> _savePlaylists() async {
    if (_storage == null) return;
    await _storage!.setPlaylistsJson(PlaylistModel.encodeList(_playlists));
  }

  Future<PlaylistModel> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: _uuid.v4(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    _playlists.add(playlist);
    await _savePlaylists();
    notifyListeners();
    return playlist;
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _playlists[index].name = newName;
      await _savePlaylists();
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0 && !_playlists[index].songIds.contains(songId)) {
      _playlists[index].songIds.add(songId);
      await _savePlaylists();
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      _playlists[index].songIds.remove(songId);
      await _savePlaylists();
      notifyListeners();
    }
  }

  PlaylistModel? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
