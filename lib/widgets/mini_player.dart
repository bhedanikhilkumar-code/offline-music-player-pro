import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart'
    hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import '../providers/theme_provider.dart';
import '../constants/app_text_styles.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart';
import '../widgets/glass_container.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;

    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        final song = audio.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PlayerScreen())),
          child: GlassContainer(
            borderRadius: 0,
            blur: 15,
            opacity: 0.15,
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator
                StreamBuilder<PositionData>(
                  stream: audio.positionDataStream,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final progress =
                        data != null && data.duration.inMilliseconds > 0
                            ? data.position.inMilliseconds /
                                data.duration.inMilliseconds
                            : 0.0;
                    return LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 2,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor:
                          AlwaysStoppedAnimation(primaryColor.withOpacity(0.8)),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 48,
                            artworkWidth: 48,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withOpacity(0.6)
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.music_note_rounded,
                                  color: Colors.white, size: 28),
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
                              style: AppTextStyles.miniPlayerTitle.copyWith(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.displayArtist,
                              style: AppTextStyles.miniPlayerArtist.copyWith(
                                  fontSize: 12, color: Colors.white60),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play/Pause Button
                      StreamBuilder<bool>(
                        stream: audio.playerStateStream.map((s) => s.playing),
                        builder: (context, snapshot) {
                          final playing = snapshot.data ?? false;
                          return IconButton(
                            onPressed: () => audio.togglePlayPause(),
                            icon: Icon(
                              playing
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_filled_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            padding: EdgeInsets.zero,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      // Next Button
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded,
                            size: 30, color: Colors.white70),
                        onPressed: () => audio.playNext(),
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
