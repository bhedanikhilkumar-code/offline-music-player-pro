import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';
import 'audio_player_service.dart';

/// Bridges [AudioPlayerService] (app-level playback) with [audio_service]
/// (OS-level media notification & foreground service).
///
/// Key design decisions:
///  • Uses the singleton [AudioPlayerService] so playback state is shared.
///  • Broadcasts [PlaybackState] and [MediaItem] whenever the player state
///    changes, keeping the system notification in sync.
///  • Handles [AudioSession] interruptions (incoming calls, other apps)
///    so playback pauses/resumes automatically.
class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _playerService = AudioPlayerService();
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _becomingNoisySub;
  bool _wasPlayingBeforeInterruption = false;

  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // ── Audio Session: focus & interruption handling ──
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Handle interruptions (phone calls, alarms, other apps)
      _interruptionSub = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          // Another app/system took audio focus
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Lower volume temporarily (e.g. navigation prompt)
              _playerService.player.setVolume(0.3);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _wasPlayingBeforeInterruption = _playerService.isPlaying;
              if (_wasPlayingBeforeInterruption) {
                _playerService.pause();
              }
              break;
          }
        } else {
          // Interruption ended — restore
          switch (event.type) {
            case AudioInterruptionType.duck:
              _playerService.player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (_wasPlayingBeforeInterruption) {
                _playerService.play();
              }
              break;
          }
        }
      });

      // Handle headphone disconnect → pause
      _becomingNoisySub = session.becomingNoisyEventStream.listen((_) {
        if (_playerService.isPlaying) {
          _playerService.pause();
        }
      });
    } catch (e) {
      debugPrint('AudioSession setup failed: $e');
    }

    // Combine multiple state streams into one to update notification.
    // We include positionStream to ensure the notification bar is responsive.
    Rx.combineLatest3<PlayerState, SongModel?, Duration, void>(
      _playerService.player.playerStateStream,
      _playerService.currentSongStream,
      _playerService.player.positionStream,
      (playerState, currentSong, position) {
        _broadcastPlaybackState();
      },
    ).listen((_) {});

    // ── Broadcast state changes to system notification ──

    _playerService.currentSongStream.listen((song) {
      _broadcastQueue();
      if (song != null) {
        _broadcastMediaItem(song);
      }
      _broadcastPlaybackState();
    });

    _playerService.player.processingStateStream.listen((_) {
      _broadcastPlaybackState();
    });

    // Emit initial state so notification appears correctly
    _broadcastPlaybackState();
  }

  void _broadcastMediaItem(SongModel song) {
    mediaItem.add(_songToMediaItem(song));
  }

  void _broadcastQueue() {
    queue.add(
      _playerService.queue.map(_songToMediaItem).toList(growable: false),
    );
  }

  MediaItem _songToMediaItem(SongModel song) {
    Uri? artUri;
    if (song.id > 0) {
      artUri = Uri.parse(
          'content://media/external/audio/media/${song.id}/albumart');
    }

    return MediaItem(
      id: song.path,
      title: song.displayTitle,
      artist: song.displayArtist,
      album: song.album,
      duration: Duration(milliseconds: song.duration),
      artUri: artUri,
    );
  }

  void _broadcastPlaybackState() {
    final player = _playerService.player;
    final playerState = player.playerState;
    final playbackEvent = player.playbackEvent;

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playerState.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapState(playerState.processingState),
      playing: playerState.playing,
      updatePosition: playbackEvent.updatePosition,
      bufferedPosition: playbackEvent.bufferedPosition,
      speed: player.speed,
      updateTime: playbackEvent.updateTime,
      queueIndex:
          _playerService.currentIndex >= 0 ? _playerService.currentIndex : null,
    ));
  }

  AudioProcessingState _mapState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  // ── Playback controls (called from notification buttons) ──

  @override
  Future<void> play() async => await _playerService.play();

  @override
  Future<void> pause() async => await _playerService.pause();

  @override
  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
    _broadcastPlaybackState();
  }

  @override
  Future<void> skipToNext() async {
    await _playerService.playNext();
    _broadcastQueue();
    _broadcastPlaybackState();
  }

  @override
  Future<void> skipToPrevious() async {
    await _playerService.playPrevious();
    _broadcastQueue();
    _broadcastPlaybackState();
  }

  @override
  Future<void> fastForward() async {
    await _playerService.seekForward();
    _broadcastPlaybackState();
  }

  @override
  Future<void> rewind() async {
    await _playerService.seekBackward();
    _broadcastPlaybackState();
  }

  @override
  Future<void> stop() async {
    await _playerService.stop();
    _interruptionSub?.cancel();
    _becomingNoisySub?.cancel();
    playbackState.add(PlaybackState(
      controls: [],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }
}
