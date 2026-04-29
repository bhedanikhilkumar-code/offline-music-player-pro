import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_player_service.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _playerService = AudioPlayerService();

  MyAudioHandler() {
    _init();
  }

  void _init() {
    _playerService.player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processingState = _mapProcessingState(state.processingState);
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
        processingState: processingState,
        playing: playing,
        updatePosition: _playerService.player.position,
        bufferedPosition: _playerService.player.bufferedPosition,
        speed: _playerService.player.speed,
      ));
    });

    _playerService.player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    _playerService.currentSongStream.listen((song) {
      if (song != null) {
        updatePlayerMetadata(song.title, song.artist, Duration(milliseconds: song.duration));
      }
    });
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

  void updatePlayerMetadata(String title, String artist, Duration? duration) {
    mediaItem.add(MediaItem(
      id: _playerService.currentSong?.path ?? '',
      title: title,
      artist: artist,
      duration: duration,
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
  Future<void> stop() async {
    await _playerService.pause();
    await super.stop();
  }
}
