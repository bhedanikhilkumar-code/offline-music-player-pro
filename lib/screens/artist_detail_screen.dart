import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/artist_model.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_sheet.dart';

class ArtistDetailScreen extends StatelessWidget {
  final ArtistModel artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicLibraryProvider>(
      builder: (context, library, _) {
        final songs = library.getSongsForArtist(artist.name);
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [AppColors.surfaceDark, AppColors.primaryDark],
              ),
            ),
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
                        IconButton(icon: const Icon(Icons.shuffle_rounded, color: Colors.white70, size: 22), onPressed: songs.isNotEmpty ? () {
                          final shuffled = List.from(songs)..shuffle();
                          context.read<AudioProvider>().setQueue(shuffled.cast(), startIndex: 0);
                        } : null),
                        IconButton(icon: const Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 26), onPressed: songs.isNotEmpty ? () {
                          context.read<AudioProvider>().playSong(songs.first, playlist: songs, index: 0);
                        } : null),
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
