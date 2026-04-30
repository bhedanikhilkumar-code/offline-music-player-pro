import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel;
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';
import 'audio_player_service.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _playerService = AudioPlayerService();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  MyAudioHandler() {
    _init();
  }

  void _init() {
    // Emit initial idle state so Android media session activates
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

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
      if (song != null) {
        _setMediaItemForSong(song);
      }
    });
  }

  /// Set media item IMMEDIATELY with basic info, then update artwork async.
  /// This ensures the notification shows title/artist even if artwork fails.
  void _setMediaItemForSong(SongModel song) {
    // Step 1: Set basic media item RIGHT NOW (sync) — no artwork yet
    try {
      mediaItem.add(MediaItem(
        id: song.path,
        title: song.displayTitle,
        artist: song.displayArtist,
        album: song.album,
        duration: Duration(milliseconds: song.duration),
      ));
    } catch (e) {
      // Should never fail, but safety first
    }

    // Step 2: Try to load artwork in background and update notification
    _loadAndSetArtwork(song);
  }

  Future<void> _loadAndSetArtwork(SongModel song) async {
    try {
      final artwork = await _audioQuery.queryArtwork(
        song.id,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 300,
      );
      if (artwork != null && artwork.isNotEmpty) {
        final artUri = await _saveArtworkToFile(artwork, song.id);
        if (artUri != null) {
          // Re-emit mediaItem with artwork URI included
          mediaItem.add(MediaItem(
            id: song.path,
            title: song.displayTitle,
            artist: song.displayArtist,
            album: song.album,
            duration: Duration(milliseconds: song.duration),
            artUri: artUri,
          ));
        }
      }
    } catch (_) {
      // Artwork failed — notification still shows title/artist from Step 1
    }
  }

  /// Save artwork bytes to a temporary file and return its URI.
  Future<Uri?> _saveArtworkToFile(Uint8List bytes, int songId) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/album_art_$songId.jpg');
      if (!file.existsSync()) {
        await file.writeAsBytes(bytes);
      }
      return file.uri;
    } catch (_) {
      return null;
    }
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
