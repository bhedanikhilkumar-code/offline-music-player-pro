import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = StorageService._(prefs);
    }
    return _instance!;
  }

  // Generic methods
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);

  Future<bool> setList(String key, List<String> value) => _prefs.setStringList(key, value);
  List<String> getList(String key) => _prefs.getStringList(key) ?? [];

  // Playback State
  int? get lastPlayedSongId => getInt('last_song_id');
  String? get lastPlayedSongTitle => getString('last_song_title');
  int get lastPlayedPosition => getInt('last_position') ?? 0;
  double get playbackSpeed => getDouble('playback_speed') ?? 1.0;
  double get volumeLevel => getDouble('volume_level') ?? 1.0;
  bool get shuffleEnabled => getBool('shuffle_enabled') ?? false;
  int get repeatMode => getInt('repeat_mode') ?? 0;

  Future<void> setLastPlayedSongId(int id) => setInt('last_song_id', id);
  Future<void> setLastPlayedSongTitle(String title) => setString('last_song_title', title);
  Future<void> setLastPlayedPosition(int ms) => setInt('last_position', ms);
  Future<void> setPlaybackSpeed(double speed) => setDouble('playback_speed', speed);
  Future<void> setVolumeLevel(double volume) => setDouble('volume_level', volume);
  Future<void> setShuffleEnabled(bool enabled) => setBool('shuffle_enabled', enabled);
  Future<void> setRepeatMode(int mode) => setInt('repeat_mode', mode);

  // Library & UI Preferences
  List<String> get hiddenSongIds => getList('hidden_song_ids');
  List<String> get hiddenFolderPaths => getList('hidden_folder_paths');
  String get sortType => getString('sort_type') ?? 'title';

  Future<void> setSortType(String value) => setString('sort_type', value);
  Future<void> setHiddenFolderPaths(List<String> paths) => setList('hidden_folder_paths', paths);

  Future<void> toggleHidden(int songId) async {
    final list = hiddenSongIds.toList();
    final idStr = songId.toString();
    if (list.contains(idStr)) {
      list.remove(idStr);
    } else {
      list.add(idStr);
    }
    await setList('hidden_song_ids', list);
  }

  // Favorites
  List<String> get favoriteIds => getList('favorite_ids');
  bool isFavorite(int songId) => favoriteIds.contains(songId.toString());
  
  Future<void> toggleFavorite(int songId) async {
    final list = favoriteIds.toList();
    final idStr = songId.toString();
    if (list.contains(idStr)) {
      list.remove(idStr);
    } else {
      list.add(idStr);
    }
    await setList('favorite_ids', list);
  }

  // Theme Preferences
  int get themeColor => getInt('theme_color') ?? 0xFF6C63FF;
  bool get isCustomThemeEnabled => getBool('is_custom_theme_enabled') ?? false;
  String? get themeBackgroundImagePath => getString('theme_bg_image_path');
  String? get themeGradient => getString('theme_gradient');

  Future<void> setThemeColor(int value) => setInt('theme_color', value);
  Future<void> setIsCustomThemeEnabled(bool value) => setBool('is_custom_theme_enabled', value);
  Future<void> setThemeBackgroundImagePath(String value) => setString('theme_bg_image_path', value);
  Future<void> setThemeGradient(String value) => setString('theme_gradient', value);

  // Playlists
  String get playlistsJson => getString('playlists') ?? '[]';
  Future<void> setPlaylistsJson(String value) => setString('playlists', value);

  // Equalizer
  bool get equalizerEnabled => getBool('eq_enabled') ?? false;
  String get equalizerPreset => getString('eq_preset') ?? 'Normal';
  List<double> get eqBandValues {
    final list = getList('eq_bands');
    if (list.isEmpty) return List.filled(5, 0.0);
    return list.map((e) => double.tryParse(e) ?? 0.0).toList();
  }
  double get bassBoostLevel => getDouble('bass_boost') ?? 0.0;
  double get virtualizerLevel => getDouble('virtualizer') ?? 0.0;

  Future<void> setEqualizerEnabled(bool value) => setBool('eq_enabled', value);
  Future<void> setEqualizerPreset(String value) => setString('eq_preset', value);
  Future<void> setEqBandValues(List<double> values) => setList('eq_bands', values.map((v) => v.toString()).toList());
  Future<void> setBassBoostLevel(double value) => setDouble('bass_boost', value);
  Future<void> setVirtualizerLevel(double value) => setDouble('virtualizer', value);

  // Lyrics
  String? getLyrics(int songId) => getString('lyrics_$songId');
  Future<void> saveLyrics(int songId, String lyrics) => setString('lyrics_$songId', lyrics);

  // Sleep Timer
  Future<void> setSleepTimerEnabled(bool value) => setBool('sleep_timer_enabled', value);
  Future<void> setSleepTimerMinutes(int value) => setInt('sleep_timer_minutes', value);

  // App Settings
  bool get permissionGranted => getBool('permission_granted') ?? false;
  Future<void> setPermissionGranted(bool value) => setBool('permission_granted', value);
  Future<void> setFirstLaunch(bool value) => setBool('first_launch', value);

  // Advanced Settings
  bool get crossfadeEnabled => getBool('crossfade_enabled') ?? false;
  bool get gaplessEnabled => getBool('gapless_enabled') ?? false;
  bool get lockScreenPlaying => getBool('lock_screen_playing') ?? true;
  bool get pauseOnHeadphoneDetach => getBool('pause_on_detach') ?? true;
  bool get notificationEnabled => getBool('notification_enabled') ?? true;
  String get selectedLanguage => getString('language') ?? 'en';
  bool get isPremiumLocal => getBool('is_premium_local') ?? false;
  bool get adsRemoved => getBool('ads_removed') ?? false;
  bool get volumeBoosterEnabled => getBool('volume_booster_enabled') ?? false;
  bool get keepScreenOn => getBool('keep_screen_on') ?? false;

  Future<void> setCrossfadeEnabled(bool value) => setBool('crossfade_enabled', value);
  Future<void> setGaplessEnabled(bool value) => setBool('gapless_enabled', value);
  Future<void> setLockScreenPlaying(bool value) => setBool('lock_screen_playing', value);
  Future<void> setPauseOnHeadphoneDetach(bool value) => setBool('pause_on_detach', value);
  Future<void> setNotificationEnabled(bool value) => setBool('notification_enabled', value);
  Future<void> setSelectedLanguage(String value) => setString('language', value);
  Future<void> setIsPremiumLocal(bool value) => setBool('is_premium_local', value);
  Future<void> setAdsRemoved(bool value) => setBool('ads_removed', value);
  Future<void> setVolumeBoosterEnabled(bool value) => setBool('volume_booster_enabled', value);
  Future<void> setKeepScreenOn(bool value) => setBool('keep_screen_on', value);

  // Privacy Settings
  bool get privacyLockEnabled => getBool('privacy_lock_enabled') ?? false;
  String? get privacyPin => getString('privacy_pin');
  Future<void> setPrivacyLockEnabled(bool value) => setBool('privacy_lock_enabled', value);
  Future<void> setPrivacyPin(String value) => setString('privacy_pin', value);
  
  // Backup
  String? get lastBackupDate => getString('last_backup_date');
  Future<void> setLastBackupDate(String value) => setString('last_backup_date', value);

  // Search
  List<String> get recentSearches => getList('recent_searches');
  Future<void> addRecentSearch(String query) async {
    final list = recentSearches.toList();
    if (list.contains(query)) list.remove(query);
    list.insert(0, query);
    if (list.length > 20) list.removeLast();
    await setList('recent_searches', list);
  }

  // History & Play Count
  List<String> get recentlyPlayedIds => getList('recently_played_ids');
  Future<void> addToRecentlyPlayed(int songId) async {
    final list = recentlyPlayedIds.toList();
    final idStr = songId.toString();
    if (list.contains(idStr)) list.remove(idStr);
    list.insert(0, idStr);
    if (list.length > 50) list.removeLast();
    await setList('recently_played_ids', list);
  }

  Map<String, int> get playCounts {
    final json = getString('play_counts') ?? '{}';
    try {
      return Map<String, int>.from(jsonDecode(json));
    } catch (_) {
      return {};
    }
  }

  Future<void> incrementPlayCount(int songId) async {
    final counts = playCounts;
    final idStr = songId.toString();
    counts[idStr] = (counts[idStr] ?? 0) + 1;
    await setString('play_counts', jsonEncode(counts));
  }

  // JSON methods
  Future<bool> setJson(String key, dynamic value) => _prefs.setString(key, jsonEncode(value));
  dynamic getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }
}
