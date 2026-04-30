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
    _broadcastPlaybackState();

    _playerService.player.playerStateStream.listen((_) {
      _broadcastPlaybackState();
    });

    _playerService.player.playbackEventStream.listen((_) {
      _broadcastPlaybackState();
    });

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
      artUri = Uri.parse('content://media/external/audio/media/${song.id}/albumart');
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
    playbackState.add(PlaybackState(
      controls: [],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }
}
