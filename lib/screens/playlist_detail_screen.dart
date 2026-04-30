import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/playlist_model.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_sheet.dart';

class PlaylistDetailScreen extends StatefulWidget {
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
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  bool get _isVirtual => widget.customSongs != null;

  List<SongModel> _getSongs(PlaylistProvider playlistProvider, MusicLibraryProvider library) {
    if (_isVirtual) return widget.customSongs!;
    final playlist = playlistProvider.getPlaylist(widget.playlistId);
    if (playlist == null) return [];
    return playlist.songIds
        .map((id) => library.getSongById(id))
        .where((s) => s != null)
        .cast<SongModel>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;

    return Consumer2<PlaylistProvider, MusicLibraryProvider>(
      builder: (context, playlistProvider, library, _) {
        final playlist = _isVirtual ? null : playlistProvider.getPlaylist(widget.playlistId);

        // If non-virtual playlist was deleted, close screen
        if (!_isVirtual && playlist == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return Scaffold(
            backgroundColor: AppColors.primaryDark,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final songs = _getSongs(playlistProvider, library);
        final displayName = widget.title ?? playlist?.name ?? 'Playlist';

        return Scaffold(
          body: Container(
            decoration: themeProvider.backgroundDecoration,
            child: SafeArea(
              child: Column(
                children: [
                  // ─── Header ───
                  _buildHeader(context, displayName, playlist, songs, playlistProvider, primaryColor),

                  // ─── Song Count + Actions ───
                  if (songs.isNotEmpty) _buildActionBar(context, songs, primaryColor),

                  // ─── Song List ───
                  Expanded(
                    child: songs.isEmpty
                        ? _buildEmptyState(primaryColor)
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              final tile = Consumer<AudioProvider>(
                                builder: (context, audio, _) => SongTile(
                                  song: song,
                                  isPlaying: audio.currentSong?.id == song.id,
                                  onTap: () => audio.playSong(song, playlist: songs, index: index),
                                  onOptionsTap: () => SongOptionsSheet.show(context, song),
                                ),
                              );

                              if (_isVirtual) return tile;

                              return Dismissible(
                                key: Key('playlist_song_${song.id}_$index'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete_rounded, color: AppColors.error, size: 22),
                                      const SizedBox(width: 8),
                                      Text('Remove', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  return await _confirmRemove(context);
                                },
                                onDismissed: (_) {
                                  playlistProvider.removeSongFromPlaylist(widget.playlistId, song.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${song.displayTitle} removed', style: AppTextStyles.bodySmall),
                                      backgroundColor: AppColors.cardDark,
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        textColor: primaryColor,
                                        onPressed: () => playlistProvider.addSongToPlaylist(widget.playlistId, song.id),
                                      ),
                                    ),
                                  );
                                },
                                child: tile,
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

  Widget _buildHeader(
    BuildContext context,
    String displayName,
    PlaylistModel? playlist,
    List<SongModel> songs,
    PlaylistProvider playlistProvider,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: AppTextStyles.headingSmall, overflow: TextOverflow.ellipsis),
                Text(
                  '${songs.length} songs',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          if (!_isVirtual && playlist != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
              color: AppColors.cardDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'rename') {
                  _showRenameDialog(context, playlist, playlistProvider);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, playlist, playlistProvider);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(children: [
                    const Icon(Icons.edit_rounded, size: 18, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text('Rename', style: AppTextStyles.bodyMedium),
                  ]),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text('Delete', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                  ]),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, List<SongModel> songs, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.shuffle_rounded,
              label: 'Shuffle',
              color: primaryColor,
              onTap: () {
                final shuffled = List<SongModel>.from(songs)..shuffle();
                context.read<AudioProvider>().setQueue(shuffled, startIndex: 0);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.play_arrow_rounded,
              label: 'Play All',
              color: Colors.white.withOpacity(0.08),
              onTap: () => context.read<AudioProvider>().playSong(songs.first, playlist: songs, index: 0),
              textColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.08),
            ),
            child: Icon(Icons.queue_music_rounded, size: 40, color: primaryColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          Text('No songs yet', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)),
          const SizedBox(height: 8),
          Text(
            'Add songs from the library\nusing the ⋮ menu on any song',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white24),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context) async {
    // No confirm dialog — use undo snackbar instead for faster UX
    return true;
  }

  void _showRenameDialog(BuildContext context, PlaylistModel playlist, PlaylistProvider provider) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename Playlist', style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: provider.getPlaylist(playlist.id) != null ? Colors.white : Colors.orange)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != playlist.name) {
                provider.renamePlaylist(playlist.id, name);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PlaylistModel playlist, PlaylistProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Playlist', style: AppTextStyles.headingSmall),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"?',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              provider.deletePlaylist(playlist.id);
              Navigator.pop(context); // Close detail screen
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color? textColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor ?? Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(color: textColor ?? Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
