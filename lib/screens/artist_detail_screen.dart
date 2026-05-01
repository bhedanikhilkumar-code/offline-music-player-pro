import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/artist_model.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_sheet.dart';
import '../widgets/glass_icon_button.dart';

class ArtistDetailScreen extends StatelessWidget {
  final ArtistModel artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicLibraryProvider, ThemeProvider>(
      builder: (context, library, themeProvider, _) {
        final songs = library.getSongsForArtist(artist.name);
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
                        Expanded(child: Text(artist.displayName, style: AppTextStyles.headingMedium, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text('${songs.length} songs', style: AppTextStyles.bodySmall),
                        const Spacer(),
                        GlassIconButton(
                          icon: Icons.shuffle_rounded,
                          size: 40,
                          iconSize: 20,
                          onTap: songs.isNotEmpty ? () {
                            final shuffled = List.from(songs)..shuffle();
                            context.read<AudioProvider>().setQueue(shuffled.cast(), startIndex: 0);
                          } : () {},
                        ),
                        const SizedBox(width: 10),
                        GlassIconButton(
                          icon: Icons.play_arrow_rounded,
                          size: 40,
                          iconSize: 24,
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
                            song: song, isPlaying: audio.currentSong?.id == song.id,
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
