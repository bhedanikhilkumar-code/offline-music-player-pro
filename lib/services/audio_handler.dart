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
    // Sync playback state to notification controls
    _playerService.player.playerStateStream.listen((state) {
      try {
        _updatePlaybackState(state.playing, state.processingState);
      } catch (e) {
        // Prevent crash if playback state update fails
      }
    });

    // Update notification metadata when song changes
    _playerService.currentSongStream.listen((song) {
      try {
        if (song != null) {
          _updateMediaItem(song);
        }
      } catch (e) {
        // Prevent crash if media item update fails
      }
    });
  }

  void _updatePlaybackState(bool playing, ProcessingState processingState) {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
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
}
