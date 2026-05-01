import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/playlist_model.dart';
import 'package:offline_music_player/services/storage_service.dart';

class SearchProvider extends ChangeNotifier {
  StorageService? _storage;
  String _query = '';
  List<SongModel> _songResults = [];
  List<AlbumModel> _albumResults = [];
  List<ArtistModel> _artistResults = [];
  List<PlaylistModel> _playlistResults = [];
  List<String> _recentSearches = [];

  String get query => _query;
  List<SongModel> get songResults => _songResults;
  List<AlbumModel> get albumResults => _albumResults;
  List<ArtistModel> get artistResults => _artistResults;
  List<PlaylistModel> get playlistResults => _playlistResults;
  List<String> get recentSearches => _recentSearches;
  bool get hasResults => _songResults.isNotEmpty || _albumResults.isNotEmpty || _artistResults.isNotEmpty || _playlistResults.isNotEmpty;

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _recentSearches = _storage?.recentSearches ?? [];
  }

  void search(String query, {
    required List<SongModel> songs,
    required List<AlbumModel> albums,
    required List<ArtistModel> artists,
    required List<PlaylistModel> playlists,
  }) {
    _query = query;
    if (query.isEmpty) {
      _songResults = [];
      _albumResults = [];
      _artistResults = [];
      _playlistResults = [];
      notifyListeners();
      return;
    }

    final q = query.toLowerCase();
    _songResults = songs.where((s) =>
        s.title.toLowerCase().contains(q) ||
        s.artist.toLowerCase().contains(q) ||
        s.album.toLowerCase().contains(q)).toList();
    _albumResults = albums.where((a) =>
        a.name.toLowerCase().contains(q) ||
        a.artist.toLowerCase().contains(q)).toList();
    _artistResults = artists.where((a) =>
        a.name.toLowerCase().contains(q)).toList();
    _playlistResults = playlists.where((p) =>
        p.name.toLowerCase().contains(q)).toList();

    notifyListeners();
  }

  Future<void> addToRecent(String query) async {
    if (query.trim().isEmpty || _storage == null) return;
    await _storage!.addRecentSearch(query.trim());
    _recentSearches = _storage!.recentSearches;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _songResults = [];
    _albumResults = [];
    _artistResults = [];
    _playlistResults = [];
    notifyListeners();
  }
}
