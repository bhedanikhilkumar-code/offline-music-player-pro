import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import 'audio_player_service.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _playerService = AudioPlayerService();

  MyAudioHandler() {
    _init();
  }

  void _init() {
    // ─── Sync playback state to notification controls ───
    _playerService.player.playerStateStream.listen((state) {
      _updatePlaybackState(state.playing, state.processingState);
    });

    // Removed positionStream listener because audio_service extrapolates position automatically.
    // Continuously updating playbackState floods the platform channel and crashes the app!

    // ─── Update notification metadata when song changes ───
    _playerService.currentSongStream.listen((song) {
      if (song != null) {
        _updateMediaItem(song);
      } else {
        mediaItem.add(null);
      }
    });
  }

  void _updatePlaybackState(bool playing, ProcessingState processingState) {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.playPause,
      },
      // Show: previous, play/pause, next in compact view
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(processingState),
      playing: playing,
      updatePosition: _playerService.player.position,
      bufferedPosition: _playerService.player.bufferedPosition,
      speed: _playerService.player.speed,
    ));
  }

  void _updateMediaItem(SongModel song) {
    Uri? artUri;
    try {
      final artPath = song.albumArtPath;
      if (artPath != null && artPath.isNotEmpty) {
        final artFile = File(artPath);
        if (artFile.existsSync()) {
          artUri = artFile.uri;
        }
      }
    } catch (_) {}

    mediaItem.add(MediaItem(
      id: song.path,
      title: song.displayTitle,
      artist: song.displayArtist,
      album: song.album,
      duration: Duration(milliseconds: song.duration),
      artUri: artUri,
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
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

  // ─── Public method for AudioProvider to call ───
  void updatePlayerMetadata(String title, String artist, Duration? duration,
      {String? albumArtPath, String? album, int? songId}) {
    Uri? artUri;
    try {
      if (albumArtPath != null && albumArtPath.isNotEmpty) {
        final artFile = File(albumArtPath);
        if (artFile.existsSync()) {
          artUri = artFile.uri;
        }
      }
    } catch (_) {}

    mediaItem.add(MediaItem(
      id: _playerService.currentSong?.path ?? '',
      title: title,
      artist: artist,
      album: album ?? '',
      duration: duration,
      artUri: artUri,
    ));
  }

  @override
  Future<void> play() async => await _playerService.play();

  @override
  Future<void> pause() async => await _playerService.pause();

  @override
  Future<void> seek(Duration position) async => await _playerService.seek(position);

  @override
  Future<void> skipToNext() async => await _playerService.playNext();

  @override
  Future<void> skipToPrevious() async => await _playerService.playPrevious();

  @override
  Future<void> fastForward() async => await _playerService.seekForward();

  @override
  Future<void> rewind() async => await _playerService.seekBackward();

  @override
  Future<void> stop() async {
    await _playerService.pause();
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    await _playerService.pause();
    await super.stop();
  }
}
