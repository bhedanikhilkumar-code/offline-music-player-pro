import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/folder_model.dart';
import '../services/music_scanner_service.dart';
import 'package:offline_music_player/services/storage_service.dart';
import '../services/permission_service.dart';
import '../utils/sort_utils.dart';

class MusicLibraryProvider extends ChangeNotifier {
  List<SongModel> _allSongs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<FolderModel> _folders = [];
  bool _isLoading = false;
  bool _initialized = false;
  String _sortType = 'title';
  StorageService? _storage;

  List<SongModel> get allSongs {
    if (!_initialized) return [];
    final hidden = _storage?.hiddenSongIds ?? [];
    final visible =
        _allSongs.where((s) => !hidden.contains(s.id.toString())).toList();
    return SortUtils.sortSongs(visible, _sortType);
  }

  List<SongModel> get allSongsUnfiltered => _allSongs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<FolderModel> get folders => _folders;
  bool get isLoading => _isLoading;
  String get sortType => _sortType;
  int get totalSongs => allSongs.length;

  List<SongModel> get hiddenSongs {
    if (!_initialized) return [];
    final hidden = _storage?.hiddenSongIds ?? [];
    return _allSongs.where((s) => hidden.contains(s.id.toString())).toList();
  }

  List<SongModel> get recentlyPlayed {
    if (!_initialized) return [];
    final ids = _storage?.recentlyPlayedIds ?? [];
    return ids
        .map((id) => getSongById(int.tryParse(id) ?? -1))
        .where((s) => s != null)
        .cast<SongModel>()
        .toList();
  }

  List<SongModel> get mostPlayed {
    if (!_initialized) return [];
    final counts = _storage?.playCounts ?? {};
    final sortedIds = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return sortedIds
        .take(20)
        .map((id) => getSongById(int.tryParse(id) ?? -1))
        .where((s) => s != null)
        .cast<SongModel>()
        .toList();
  }

  List<SongModel> get favorites {
    if (!_initialized) return [];
    final ids = _storage?.favoriteIds ?? [];
    return ids
        .map((id) => getSongById(int.tryParse(id) ?? -1))
        .where((s) => s != null)
        .cast<SongModel>()
        .toList();
  }

  Future<void> init(StorageService storage, {bool forceRescan = false}) async {
    _storage = storage;
    _sortType = _storage?.sortType ?? 'title';

    // If already initialized and no force rescan, skip
    if (_initialized && !forceRescan) return;

    // Always try to scan - if permission is not granted, scanMusic will return empty
    final hasPermission = await PermissionService.hasStoragePermission();
    if (hasPermission || forceRescan) {
      await scanMusic();
    }
    // Mark as initialized even if permission wasn't granted
    // This prevents repeated init attempts that could freeze the UI
    _initialized = true;
  }

  /// Call this after permission is granted to load music
  Future<void> loadAfterPermissionGranted() async {
    if (_storage == null) return;
    await scanMusic();
    notifyListeners();
  }

  Future<void> scanMusic() async {
    _isLoading = true;
    notifyListeners();

    _allSongs = await MusicScannerService.scanSongs();
    _albums = await MusicScannerService.scanAlbums();
    _artists = await MusicScannerService.scanArtists();
    _buildFolders();

    _isLoading = false;
    notifyListeners();
  }

  void _buildFolders() {
    final Map<String, List<SongModel>> folderMap = {};
    final hiddenFolders = _storage?.hiddenFolderPaths ?? [];

    for (final song in _allSongs) {
      final folder = song.folderPath;
      if (!hiddenFolders.contains(folder)) {
        folderMap.putIfAbsent(folder, () => []).add(song);
      }
    }

    _folders = folderMap.entries
        .map((e) => FolderModel(
              path: e.key,
              name: e.key.split('/').last,
              songs: e.value,
            ))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void setSortType(String type) {
    _sortType = type;
    if (_initialized) _storage?.setSortType(type);
    notifyListeners();
  }

  List<SongModel> getSongsForAlbum(int albumId) {
    return _allSongs.where((s) => s.albumId == albumId).toList();
  }

  List<SongModel> getSongsForArtist(String artistName) {
    return _allSongs.where((s) => s.artist == artistName).toList();
  }

  List<SongModel> getSongsForFolder(String folderPath) {
    return _allSongs.where((s) => s.folderPath == folderPath).toList();
  }

  Future<void> hideSong(int songId) async {
    if (_initialized) await _storage?.toggleHidden(songId);
    notifyListeners();
  }

  Future<void> unhideSong(int songId) async {
    if (_initialized) await _storage?.toggleHidden(songId);
    notifyListeners();
  }

  Future<void> toggleFavorite(int songId) async {
    if (_initialized) await _storage?.toggleFavorite(songId);
    notifyListeners();
  }

  Future<void> hideFolder(String path) async {
    if (!_initialized || _storage == null) return;
    final paths = _storage!.hiddenFolderPaths;
    if (!paths.contains(path)) {
      paths.add(path);
      await _storage!.setHiddenFolderPaths(paths);
      _buildFolders();
      notifyListeners();
    }
  }

  void updateSong(SongModel updatedSong) {
    final index = _allSongs.indexWhere((s) => s.id == updatedSong.id);
    if (index != -1) {
      _allSongs[index] = updatedSong;
      _buildFolders();
      notifyListeners();
    }
  }

  SongModel? getSongById(int id) {
    try {
      return _allSongs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
