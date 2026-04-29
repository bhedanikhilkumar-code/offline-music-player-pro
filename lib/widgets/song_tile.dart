import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../constants/app_text_styles.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onOptionsTap;
  final bool isPlaying;
  final int? index;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onOptionsTap,
    this.isPlaying = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;
    
    // Format date added as MM-dd
    final dateAdded = DateTime.fromMillisecondsSinceEpoch((song.dateAdded > 0 ? song.dateAdded : DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000);
    final dateStr = DateFormat('MM-dd').format(dateAdded);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Subtle Album Art Background (The "Behind" art the user requested)
              Positioned.fill(
                child: Opacity(
                  opacity: isPlaying ? 0.15 : 0.05,
                  child: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: const SizedBox.shrink(),
                  ),
                ),
              ),
              // Blurred Layer
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
              
              // Content
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isPlaying ? Colors.white.withOpacity(0.05) : Colors.transparent,
                  border: isPlaying ? Border.all(color: Colors.white12, width: 0.5) : null,
                ),
                child: Row(
                  children: [
                    // Artwork with Hero
                    Hero(
                      tag: isPlaying ? 'album_art' : 'song_art_${song.id}',
                      child: Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF252344),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 56, artworkWidth: 56,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white10, Colors.white.withOpacity(0.05)],
                                ),
                              ),
                              child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.displayTitle,
                            style: AppTextStyles.songTitle.copyWith(
                              color: isPlaying ? primaryColor : Colors.white,
                              fontSize: 16,
                              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                              shadows: isPlaying ? [Shadow(color: Colors.black45, blurRadius: 4)] : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.displayArtist,
                            style: AppTextStyles.songSubtitle.copyWith(color: Colors.white54, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Trailing
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPlaying)
                          const _PlayingVisualizer()
                        else
                          Text(dateStr, style: AppTextStyles.songSubtitle.copyWith(color: Colors.white24, fontSize: 11)),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 22),
                          onPressed: onOptionsTap,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayingVisualizer extends StatefulWidget {
  const _PlayingVisualizer();
  @override
  State<_PlayingVisualizer> createState() => _PlayingVisualizerState();
}

class _PlayingVisualizerState extends State<_PlayingVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double height = 4 + (12 * (0.5 + 0.5 * (index == 0 ? _controller.value : (index == 1 ? (1 - _controller.value) : (_controller.value * 0.7)))));
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: context.read<ThemeProvider>().primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
