import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> init() async {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongComplete();
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
    if (playlist != null) {
      _queue = List.from(playlist);
      _currentIndex = index ?? playlist.indexOf(song);
    } else if (!_queue.contains(song)) {
      _queue = [song];
      _currentIndex = 0;
    } else {
      _currentIndex = _queue.indexOf(song);
    }
    await _playCurrentSong();
  }

  Future<void> _playCurrentSong({int failedAttempts = 0}) async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) {
      _currentSongSubject.add(null);
      return;
    }
    final song = _queue[_currentIndex];
    try {
      await _player.setAudioSource(_audioSourceFor(song));
      _currentSongSubject.add(song);
      await _player.play();
    } catch (e) {
      debugPrint('Playback failed for ${song.path}: $e');
      if (failedAttempts < _queue.length - 1 && _advanceAfterPlaybackError()) {
        await _playCurrentSong(failedAttempts: failedAttempts + 1);
      } else {
        _currentSongSubject.add(null);
        await _player.stop();
      }
    }
  }

  AudioSource _audioSourceFor(SongModel song) {
    final contentUri = song.uri?.trim();
    if (contentUri != null && contentUri.isNotEmpty) {
      return AudioSource.uri(Uri.parse(contentUri));
    }
    return AudioSource.file(song.path);
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

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();

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
    if (_queue.isEmpty) return;
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
    await _playCurrentSong();
  }

  Future<void> playPrevious() async {
    if (_queue.isEmpty) return;
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
    await _playCurrentSong();
  }

  void toggleShuffle() {
    _shuffleMode = !_shuffleMode;
    if (_shuffleMode && _queue.length > 1) {
      final current = _queue[_currentIndex];
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
    _currentIndex = startIndex;
    await _playCurrentSong();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    if (index == _currentIndex) return;
    _queue.removeAt(index);
    if (index < _currentIndex) _currentIndex--;
    _currentSongSubject.add(currentSong);
  }

  Future<void> dispose() async {
    await _currentSongSubject.close();
    await _player.dispose();
  }
}
