import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/permission_service.dart';
import 'package:offline_music_player/services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _playerService = AudioPlayerService();
  late StorageService _storage;
  bool _initialized = false;

  SongModel? get currentSong => _playerService.currentSong;
  List<SongModel> get queue => _playerService.queue;
  int get currentIndex => _playerService.currentIndex;
  bool get shuffleMode => _playerService.shuffleMode;
  int get repeatMode => _playerService.repeatMode;
  bool get isPlaying => _playerService.isPlaying;
  AudioPlayerService get playerService => _playerService;
  int get androidAudioSessionId => _playerService.androidAudioSessionId;

  Stream<PlayerState> get playerStateStream => _playerService.playerStateStream;
  Stream<Duration?> get durationStream => _playerService.durationStream;
  Stream<Duration> get positionStream => _playerService.positionStream;
  Stream<PositionData> get positionDataStream =>
      _playerService.positionDataStream;

  Future<void> init(StorageService storage) async {
    if (_initialized) return;
    _storage = storage;
    await _playerService.init();

    // Restore playback state
    final speed = _storage.playbackSpeed;
    await _playerService.setSpeed(speed);
    await PermissionService.requestNotificationPermission();

    _playerService.player.playerStateStream.listen((state) {
      _storage.setIsCurrentlyPlaying(state.playing);
      notifyListeners();
    });

    // Listen for track changes to update history
    _playerService.currentSongStream.listen((song) {
      if (song != null) {
        _storage.setLastPlayedSongId(song.id);
        _storage.setLastPlayedSongTitle(song.title);
        _storage.setLastPlayedArtist(song.artist);
        _storage.addToRecentlyPlayed(song.id);
        _storage.incrementPlayCount(song.id);
        notifyListeners();
      }
    });

    _initialized = true;
  }

  Future<void> playSong(SongModel song,
      {List<SongModel>? playlist, int? index}) async {
    await PermissionService.requestNotificationPermission();
    await _playerService.playSong(song, playlist: playlist, index: index);
    notifyListeners();
  }

  Future<void> play() async {
    await PermissionService.requestNotificationPermission();
    await _playerService.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _playerService.pause();
    if (currentSong != null) {
      _storage
          .setLastPlayedPosition(_playerService.player.position.inMilliseconds);
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    await PermissionService.requestNotificationPermission();
    await _playerService.togglePlayPause();
    notifyListeners();
  }

  Future<void> playNext() async {
    await _playerService.playNext();
    notifyListeners();
  }

  Future<void> playPrevious() async {
    await _playerService.playPrevious();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
  }

  Future<void> seekForward() async => await _playerService.seekForward();
  Future<void> seekBackward() async => await _playerService.seekBackward();

  void toggleShuffle() {
    _playerService.toggleShuffle();
    _storage.setShuffleEnabled(_playerService.shuffleMode);
    notifyListeners();
  }

  void toggleRepeat() {
    _playerService.toggleRepeat();
    _storage.setRepeatMode(_playerService.repeatMode);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    await _playerService.setSpeed(speed);
    _storage.setPlaybackSpeed(speed);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _playerService.setVolume(volume);
    _storage.setVolumeLevel(volume);
    notifyListeners();
  }

  Future<void> setQueue(List<SongModel> songs, {int startIndex = 0}) async {
    await PermissionService.requestNotificationPermission();
    await _playerService.setQueue(songs, startIndex: startIndex);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _playerService.removeFromQueue(index);
    notifyListeners();
  }

  double get speed => _playerService.player.speed;
  double get volume => _playerService.player.volume;
}
