import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart'
    hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../services/ringtone_service.dart';
import '../screens/tag_editor_screen.dart';

class SongOptionsSheet extends StatelessWidget {
  final SongModel song;
  const SongOptionsSheet({super.key, required this.song});

  static void show(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SongOptionsSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: const Color(0xFF1E1E1E).withOpacity(0.85), // Premium dark translucent
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Song info
                      Row(
                        children: [
                          QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 56,
                            artworkWidth: 56,
                            artworkBorder: BorderRadius.circular(12),
                            nullArtworkWidget: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.08),
                              ),
                              child: const Icon(Icons.music_note_rounded, color: Colors.white54, size: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(song.displayTitle,
                                    style: AppTextStyles.songTitle.copyWith(fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                    '${song.displayArtist} | ${song.durationFormatted} | ${song.bitrateFormatted}',
                                    style: AppTextStyles.songSubtitle.copyWith(fontSize: 12, color: Colors.white54)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.ios_share_rounded, color: Colors.white70),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Action grid Row 1
                      Row(
                        children: [
                          Expanded(child: _actionButton(context, Icons.notifications_none_rounded, 'Set as ringtone', () async {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                            final success = await RingtoneService.setAsRingtone(song.path);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Ringtone set successfully' : 'Failed to set ringtone')),
                              );
                            }
                          })),
                          const SizedBox(width: 12),
                          Expanded(child: _actionButton(context, Icons.image_outlined, 'Change cover', () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TagEditorScreen(song: song)));
                          })),
                          const SizedBox(width: 12),
                          Expanded(child: _actionButton(context, Icons.local_offer_outlined, 'Edit tags', () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TagEditorScreen(song: song)));
                          })),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Action grid Row 2
                      Row(
                        children: [
                          Expanded(child: _actionButton(context, Icons.album_outlined, 'Go to album', () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          })),
                          const SizedBox(width: 12),
                          Expanded(child: _actionButton(context, Icons.visibility_off_outlined, 'Hide song', () {
                            context.read<MusicLibraryProvider>().hideSong(song.id);
                            if (Navigator.canPop(context)) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song hidden')));
                          })),
                          const SizedBox(width: 12),
                          Expanded(child: _actionButton(context, Icons.delete_outline_rounded, 'Delete from device', () {
                            _showDeleteConfirmation(context);
                          })),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // List options
                      _listTile(Icons.playlist_play_rounded, 'Play next', onTap: () {
                        context.read<AudioProvider>().addToQueue(song, insertNext: true);
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      }),
                      _listTile(Icons.queue_music_rounded, 'Add to queue', onTap: () {
                        context.read<AudioProvider>().addToQueue(song);
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      }),
                      _listTile(Icons.playlist_add_rounded, 'Add to playlist', onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        // Implement add to playlist flow
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08), // Light frosted look
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 8),
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 28),
      title: Text(title, style: AppTextStyles.songTitle.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.confirm, style: AppTextStyles.headingSmall),
        content: Text('Delete "${song.displayTitle}" from device?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel, style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete feature requires MANAGE_EXTERNAL_STORAGE')));
            },
            child: Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
