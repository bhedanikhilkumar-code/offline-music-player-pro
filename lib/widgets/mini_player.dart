import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        final song = audio.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen())),
          child: Container(
            color: AppColors.cardDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator
                StreamBuilder<PositionData>(
                  stream: audio.positionDataStream,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final progress = data != null && data.duration.inMilliseconds > 0
                        ? data.position.inMilliseconds / data.duration.inMilliseconds
                        : 0.0;
                    return LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Album art
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: ClipOval(
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 46, artworkWidth: 46,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: Container(
                              width: 46, height: 46,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFE91E63), Color(0xFF3F51B5)],
                                ),
                              ),
                              child: const Icon(Icons.music_note_rounded, color: Colors.white70, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Song info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              song.displayTitle,
                              style: AppTextStyles.miniPlayerTitle.copyWith(fontSize: 15),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${song.displayArtist} - Music 🎶',
                              style: AppTextStyles.miniPlayerArtist.copyWith(fontSize: 12, color: Colors.white54),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play/Pause Button
                      StreamBuilder<bool>(
                        stream: audio.playerStateStream.map((s) => s.playing),
                        builder: (context, snapshot) {
                          final playing = snapshot.data ?? false;
                          return GestureDetector(
                            onTap: () => audio.togglePlayPause(),
                            child: Container(
                              width: 42, height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // Queue Icon
                      IconButton(
                        icon: const Icon(Icons.playlist_play_rounded, size: 32),
                        color: Colors.white,
                        onPressed: () {
                          // Could open current queue sheet
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
