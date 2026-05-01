import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart'
    hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
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
    // on_audio_query returns dateAdded in seconds since epoch
    final dateAddedSeconds = song.dateAdded > 0 ? song.dateAdded : 0;
    final dateAdded =
        DateTime.fromMillisecondsSinceEpoch(dateAddedSeconds * 1000);
    final dateStr = DateFormat('MM-dd').format(dateAdded);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                isPlaying ? Colors.white.withOpacity(0.05) : Colors.transparent,
            border: isPlaying
                ? Border.all(color: Colors.white12, width: 0.5)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.05), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkHeight: 48,
                        artworkWidth: 48,
                        artworkFit: BoxFit.cover,
                        nullArtworkWidget: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: const Icon(Icons.music_note_rounded,
                              color: Colors.white38, size: 24),
                        ),
                      ),
                      if (isPlaying)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: const Center(
                            child: _PlayingVisualizer(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                        fontSize: 15,
                        fontWeight:
                            isPlaying ? FontWeight.bold : FontWeight.w500,
                        shadows: isPlaying
                            ? [Shadow(color: Colors.black45, blurRadius: 4)]
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${song.displayArtist} - ${(song.album == null || song.album == '<unknown>') ? 'Music' : song.album}',
                      style: AppTextStyles.songSubtitle
                          .copyWith(color: Colors.white54, fontSize: 12),
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
                  Text(dateStr,
                      style: AppTextStyles.songSubtitle
                          .copyWith(color: Colors.white24, fontSize: 11)),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.white38, size: 22),
                    onPressed: onOptionsTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
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

class _PlayingVisualizerState extends State<_PlayingVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Smooth sine wave animation with phase offset for each bar
            final double phase = index * (math.pi / 2.5);
            final double value =
                math.sin((_controller.value * 2 * math.pi) + phase);
            // Map the -1.0 to 1.0 sine wave to a height between 6 and 18
            final double height = 6 + (12 * ((value + 1) / 2));

            return Container(
              width: 4,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
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
