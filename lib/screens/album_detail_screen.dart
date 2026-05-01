import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_text_styles.dart';
import '../models/album_model.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_sheet.dart';
import '../widgets/glass_icon_button.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;
  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicLibraryProvider, ThemeProvider>(
      builder: (context, library, themeProvider, _) {
        final songs = library.getSongsForAlbum(album.id);
        return Scaffold(
          body: Container(
            decoration: themeProvider.backgroundDecoration,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(album.displayName, style: AppTextStyles.headingMedium, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  // Album header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF3F51B5)]),
                          ),
                          child: const Icon(Icons.album_rounded, size: 40, color: Colors.white70),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(album.displayArtist, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                              Text('${songs.length} songs', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        GlassIconButton(
                          icon: Icons.shuffle_rounded,
                          size: 44,
                          iconSize: 22,
                          onTap: songs.isNotEmpty ? () {
                            final shuffled = List.from(songs)..shuffle();
                            context.read<AudioProvider>().setQueue(shuffled.cast(), startIndex: 0);
                          } : () {},
                        ),
                        const SizedBox(width: 8),
                        GlassIconButton(
                          icon: Icons.play_arrow_rounded,
                          size: 44,
                          iconSize: 26,
                          onTap: songs.isNotEmpty ? () {
                            context.read<AudioProvider>().playSong(songs.first, playlist: songs, index: 0);
                          } : () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Consumer<AudioProvider>(
                          builder: (context, audio, _) => SongTile(
                            song: song,
                            isPlaying: audio.currentSong?.id == song.id,
                            onTap: () => audio.playSong(song, playlist: songs, index: index),
                            onOptionsTap: () => SongOptionsSheet.show(context, song),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
