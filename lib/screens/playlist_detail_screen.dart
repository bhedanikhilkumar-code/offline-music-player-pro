import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/playlist_model.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_sheet.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  final List<SongModel>? customSongs;
  final String? title;
  
  const PlaylistDetailScreen({
    super.key, 
    required this.playlistId,
    this.customSongs,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistProvider, MusicLibraryProvider>(
      builder: (context, playlistProvider, library, _) {
        final isVirtual = customSongs != null;
        final playlist = isVirtual ? null : playlistProvider.getPlaylist(playlistId);
        
        if (!isVirtual && playlist == null) {
          return Scaffold(body: Center(child: Text('Playlist not found', style: AppTextStyles.bodyMedium)));
        }

        final songs = isVirtual ? customSongs! : playlist!.songIds
            .map((id) => library.getSongById(id))
            .where((s) => s != null)
            .map((s) => s!)
            .toList();

        final displayName = title ?? playlist?.name ?? 'Playlist';

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
                        Expanded(child: Text(displayName, style: AppTextStyles.headingMedium, overflow: TextOverflow.ellipsis)),
                        if (!isVirtual)
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            color: AppColors.cardDark,
                            itemBuilder: (_) => [
                              PopupMenuItem(child: const Text('Rename'), onTap: () => _showRenameDialog(context, playlist!)),
                              PopupMenuItem(child: Text('Delete', style: TextStyle(color: AppColors.error)), onTap: () {
                                playlistProvider.deletePlaylist(playlistId);
                                Navigator.pop(context);
                              }),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text('${songs.length} songs', style: AppTextStyles.bodySmall),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.shuffle_rounded, size: 22, color: Colors.white70),
                          onPressed: songs.isNotEmpty ? () {
                            final shuffled = List.from(songs)..shuffle();
                            context.read<AudioProvider>().setQueue(shuffled.cast(), startIndex: 0);
                          } : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_arrow_rounded, size: 26, color: Colors.white70),
                          onPressed: songs.isNotEmpty ? () {
                            context.read<AudioProvider>().playSong(songs.first, playlist: songs, index: 0);
                          } : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: songs.isEmpty
                        ? Center(child: Text('No songs in playlist', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)))
                        : ListView.builder(
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              final songTile = Consumer<AudioProvider>(
                                  builder: (context, audio, _) => SongTile(
                                    song: song,
                                    isPlaying: audio.currentSong?.id == song.id,
                                    onTap: () => audio.playSong(song, playlist: songs, index: index),
                                    onOptionsTap: () => SongOptionsSheet.show(context, song),
                                  ),
                                );
                                
                                if (isVirtual) return songTile;

                               return Dismissible(
                                 key: Key('${song.id}'),
                                 direction: DismissDirection.endToStart,
                                 background: Container(
                                   color: AppColors.error.withOpacity(0.3),
                                   alignment: Alignment.centerRight,
                                   padding: const EdgeInsets.only(right: 16),
                                   child: const Icon(Icons.delete, color: Colors.white),
                                 ),
                                 onDismissed: (_) => playlistProvider.removeSongFromPlaylist(playlistId, song.id),
                                 child: songTile,
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

  void _showRenameDialog(BuildContext context, PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text('Rename Playlist', style: AppTextStyles.headingSmall),
          content: TextField(
            controller: controller, autofocus: true, style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(hintText: 'Playlist name', hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<PlaylistProvider>().renamePlaylist(playlist.id, controller.text.trim());
                Navigator.pop(context);
              }
            }, child: const Text('Rename')),
          ],
        ),
      );
    });
  }
}
