class AppConstants {
  // SharedPreferences keys
  static const String keyThemeColor = 'theme_color';
  static const String keyThemeGradient = 'theme_gradient';
  static const String keyThemeBackgroundImagePath = 'theme_background_image_path';
  static const String keyIsCustomThemeEnabled = 'is_custom_theme_enabled';
  static const String keySelectedThemeId = 'selected_theme_id';

  static const String keyLastPlayedSongId = 'last_played_song_id';
  static const String keyLastPlayedSongTitle = 'last_played_song_title';
  static const String keyLastPlayedPosition = 'last_played_position';
  static const String keyShuffleEnabled = 'shuffle_enabled';
  static const String keyRepeatMode = 'repeat_mode';
  static const String keySelectedTab = 'selected_tab';
  static const String keySortType = 'sort_type';

  static const String keyRecentSearches = 'recent_searches';
  static const String keyLastSearchQuery = 'last_search_query';

  static const String keyCrossfadeEnabled = 'crossfade_enabled';
  static const String keyGaplessEnabled = 'gapless_enabled';
  static const String keyKeepScreenOn = 'keep_screen_on';
  static const String keyLockScreenPlaying = 'lock_screen_playing';
  static const String keyPauseOnHeadphoneDetach = 'pause_on_headphone_detach';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyHiddenSongIds = 'hidden_song_ids';
  static const String keyIsPremiumLocal = 'is_premium_local';

  static const String keyCurrentSongId = 'current_song_id';
  static const String keyCurrentSongPath = 'current_song_path';
  static const String keyCurrentSongPosition = 'current_song_position';
  static const String keyFavoriteSongIds = 'favorite_song_ids';
  static const String keyPlaylistSongIds = 'playlist_song_ids';
  static const String keySleepTimerMinutes = 'sleep_timer_minutes';

  static const String keyCustomCoverPaths = 'custom_cover_paths';
  static const String keySongPlaybackSpeed = 'song_playback_speed';
  static const String keyVolumeLevel = 'volume_level';
  static const String keyVolumeBoostLevel = 'volume_boost_level';

  static const String keyLyricsJson = 'lyrics_json';

  static const String keyEqualizerEnabled = 'equalizer_enabled';
  static const String keyEqualizerPreset = 'equalizer_preset';
  static const String keyEqBand60Hz = 'eq_band_60hz';
  static const String keyEqBand230Hz = 'eq_band_230hz';
  static const String keyEqBand910Hz = 'eq_band_910hz';
  static const String keyEqBand3600Hz = 'eq_band_3600hz';
  static const String keyEqBand14000Hz = 'eq_band_14000hz';
  static const String keyBassBoostLevel = 'bass_boost_level';
  static const String keyVirtualizerLevel = 'virtualizer_level';

  static const String keyPlaylistsJson = 'playlists_json';

  static const String keyDrawerLastOpened = 'drawer_last_opened';
  static const String keyAdsRemoved = 'ads_removed';
  static const String keyVolumeBoosterEnabled = 'volume_booster_enabled';

  static const String keyHiddenFolderPaths = 'hidden_folder_paths';
  static const String keyLastOpenedFolderPath = 'last_opened_folder_path';
  static const String keyLastOpenedAlbumId = 'last_opened_album_id';

  static const String keySleepTimerEnabled = 'sleep_timer_enabled';
  static const String keySleepTimerEndTime = 'sleep_timer_end_time';

  static const String keyPermissionGranted = 'permission_granted';
  static const String keyFirstLaunch = 'first_launch';

  // Sort types
  static const String sortByTitle = 'title';
  static const String sortByArtist = 'artist';
  static const String sortByAlbum = 'album';
  static const String sortByDuration = 'duration';
  static const String sortByDate = 'date';
  static const String sortBySize = 'size';

  // Repeat modes
  static const int repeatOff = 0;
  static const int repeatAll = 1;
  static const int repeatOne = 2;

  // Playback speeds
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  // Sleep timer presets (in minutes)
  static const List<int> sleepTimerPresets = [5, 10, 15, 30, 60];

  // Volume boost presets
  static const List<int> volumeBoostPresets = [125, 150, 175, 200];

  // EQ frequency labels
  static const List<String> eqBandLabels = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];

  // EQ presets — values in dB (-15 to 15) for [60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz]
  static const Map<String, List<double>> eqPresets = {
    'Custom': [0, 0, 0, 0, 0],
    'Normal': [0, 0, 0, 0, 0],
    'Pop': [1, 3, 5, 3, 1],
    'Rock': [5, 3, -1, 4, 6],
    'Hip Hop': [6, 4, 0, 2, 3],
    'Dance': [4, 6, 3, 0, 2],
    'Classical': [-2, 0, 0, 3, 5],
    'Jazz': [3, 1, -1, 2, 4],
    'R&B': [4, 7, 2, -1, 3],
    'Electronic': [5, 3, 0, 2, 5],
    'Vocal': [-2, 0, 4, 5, 2],
    'Acoustic': [3, 1, 0, 2, 3],
    'Bass Heavy': [8, 6, 0, -1, -2],
    'Loudness': [6, 3, -1, 3, 6],
  };

  // App version
  static const String appVersion = '1.0.0';
}
