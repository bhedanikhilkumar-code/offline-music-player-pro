import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  PositionData(this.position, this.bufferedPosition, this.duration);
}

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  /// Android audio session ID for connecting native audio effects
  int _androidAudioSessionId = 0;
  int get androidAudioSessionId => _androidAudioSessionId;

  final BehaviorSubject<SongModel?> _currentSongSubject =
      BehaviorSubject<SongModel?>.seeded(null);
  Stream<SongModel?> get currentSongStream => _currentSongSubject.stream;

  List<SongModel> _queue = [];
  int _currentIndex = -1;
  bool _shuffleMode = false;
  int _repeatMode = 0; // 0=off, 1=all, 2=one
  int _playRequestId = 0;
  Future<void> _playbackOperation = Future.value();

  List<SongModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;
  bool get shuffleMode => _shuffleMode;
  int get repeatMode => _repeatMode;
  bool get isPlaying => _player.playing;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  bool _songCompleted = false;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && !_songCompleted) {
        _songCompleted = true;
        _handleSongComplete();
        // Reset flag after a short delay to allow next completion
        Future.delayed(const Duration(milliseconds: 500), () {
          _songCompleted = false;
        });
      }
    });

    // Capture Android audio session ID for native equalizer
    _player.androidAudioSessionIdStream.listen((sessionId) {
      if (sessionId != null) {
        _androidAudioSessionId = sessionId;
      }
    });
  }

  Future<void> playSong(SongModel song,
      {List<SongModel>? playlist, int? index}) async {
    if (playlist != null && playlist.isNotEmpty) {
      _queue = List.from(playlist);
      final resolvedIndex = index != null && index >= 0 && index < _queue.length
          ? index
          : _queue.indexOf(song);
      if (resolvedIndex >= 0) {
        _currentIndex = resolvedIndex;
      } else {
        _queue.insert(0, song);
        _currentIndex = 0;
      }
    } else if (!_queue.contains(song)) {
      _queue = [song];
      _currentIndex = 0;
    } else {
      _currentIndex = _queue.indexOf(song);
    }
    await _playCurrentSong(requestId: ++_playRequestId);
  }

  Future<void> _playCurrentSong({
    int failedAttempts = 0,
    required int requestId,
  }) {
    final operation = _playbackOperation.then(
      (_) => _playCurrentSongLocked(
        failedAttempts: failedAttempts,
        requestId: requestId,
      ),
    );
    _playbackOperation = operation.catchError((_) {});
    return operation;
  }

  Future<void> _playCurrentSongLocked({
    int failedAttempts = 0,
    required int requestId,
  }) async {
    if (requestId != _playRequestId) return;
    if (_currentIndex < 0 || _currentIndex >= _queue.length) {
      _currentIndex = -1;
      _currentSongSubject.add(null);
      await _player.stop();
      return;
    }
    final song = _queue[_currentIndex];
    try {
      await _player.setAudioSource(_audioSourceFor(song));
      if (requestId != _playRequestId) return;
      _currentSongSubject.add(song);

      try {
        await _player.play();
      } catch (playError) {
        debugPrint('Player.play() failed: $playError');
        rethrow;
      }
    } catch (e) {
      if (requestId != _playRequestId) return;
      debugPrint('Playback initiation failed for ${song.path}: $e');
      
      if (failedAttempts < _queue.length - 1 && _advanceAfterPlaybackError()) {
        await _playCurrentSongLocked(
          failedAttempts: failedAttempts + 1,
          requestId: requestId,
        );
      } else {
        _currentIndex = -1;
        _currentSongSubject.add(null);
        await _player.stop();
      }
    }
  }

  AudioSource _audioSourceFor(SongModel song) {
    final contentUri = song.uri?.trim();
    // Prefer content URI over file path as it's more reliable on Android
    if (contentUri != null && contentUri.isNotEmpty) {
      try {
        return AudioSource.uri(Uri.parse(contentUri));
      } catch (e) {
        debugPrint('Failed to create URI audio source: $e');
        // Fall through to file path
      }
    }
    // Fallback to file path
    try {
      return AudioSource.file(song.path);
    } catch (e) {
      debugPrint('Failed to create file audio source: $e');
      rethrow;
    }
  }

  bool _advanceAfterPlaybackError() {
    if (_queue.length <= 1) return false;
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      return true;
    }
    if (_repeatMode == 1) {
      _currentIndex = 0;
      return true;
    }
    return false;
  }

  Future<void> play() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    await _player.play();
  }

  Future<void> pause() async => await _player.pause();

  Future<void> stop() async {
    final requestId = ++_playRequestId;
    final operation = _playbackOperation.then((_) async {
      if (requestId != _playRequestId) return;
      await _player.stop();
      _currentIndex = -1;
      _queue = [];
      _currentSongSubject.add(null);
    });
    _playbackOperation = operation.catchError((_) {});
    return operation;
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> seekForward() async {
    final pos = _player.position + const Duration(seconds: 10);
    final dur = _player.duration ?? Duration.zero;
    await seek(pos > dur ? dur : pos);
  }

  Future<void> seekBackward() async {
    final pos = _player.position - const Duration(seconds: 10);
    await seek(pos < Duration.zero ? Duration.zero : pos);
  }

  Future<void> playNext() async {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) {
      return;
    }
    if (_repeatMode == 2) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_repeatMode == 1) {
      _currentIndex = 0;
    } else {
      return;
    }
    await _playCurrentSong(requestId: ++_playRequestId);
  }

  Future<void> playPrevious() async {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) {
      return;
    }
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_repeatMode == 1) {
      _currentIndex = _queue.length - 1;
    } else {
      await _player.seek(Duration.zero);
      return;
    }
    await _playCurrentSong(requestId: ++_playRequestId);
  }

  void toggleShuffle() {
    _shuffleMode = !_shuffleMode;
    final current = currentSong;
    if (_shuffleMode && current != null && _queue.length > 1) {
      _queue.shuffle();
      _queue.remove(current);
      _queue.insert(0, current);
      _currentIndex = 0;
    }
  }

  void toggleRepeat() {
    _repeatMode = (_repeatMode + 1) % 3;
  }

  void setRepeatMode(int mode) {
    _repeatMode = mode;
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  void _handleSongComplete() {
    playNext();
  }

  Future<void> setQueue(List<SongModel> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    if (_queue.isEmpty) {
      _currentIndex = -1;
      _currentSongSubject.add(null);
      await _player.stop();
      return;
    }
    _currentIndex =
        startIndex >= 0 && startIndex < _queue.length ? startIndex : 0;
    await _playCurrentSong(requestId: ++_playRequestId);
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    if (index == _currentIndex) return;
    _queue.removeAt(index);
    if (index < _currentIndex) _currentIndex--;
    _currentSongSubject.add(currentSong);
  }

  Future<void> addToQueue(SongModel song, {bool insertNext = false}) async {
    if (_queue.isEmpty) {
      await setQueue([song], startIndex: 0);
      return;
    }
    if (insertNext) {
      final insertIndex = _currentIndex >= 0 && _currentIndex < _queue.length
          ? _currentIndex + 1
          : _queue.length;
      _queue.insert(insertIndex, song);
    } else {
      _queue.add(song);
    }
  }

  Future<void> dispose() async {
    await _currentSongSubject.close();
    await _player.dispose();
  }
}
