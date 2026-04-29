import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/settings_provider.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'package:offline_music_player/services/ringtone_service.dart';
import '../screens/tag_editor_screen.dart';

class SongOptionsSheet extends StatelessWidget {
  final SongModel song;
  const SongOptionsSheet({super.key, required this.song});

  static void show(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bottomSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => SongOptionsSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Song info
                Row(
                  children: [
                    QueryArtworkWidget(
                      id: song.id, type: ArtworkType.AUDIO,
                      artworkHeight: 50, artworkWidth: 50,
                      artworkBorder: BorderRadius.circular(8),
                      nullArtworkWidget: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF3F51B5)]),
                        ),
                        child: const Icon(Icons.music_note, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.displayTitle, style: AppTextStyles.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${song.displayArtist} | ${song.durationFormatted} | ${song.bitrateFormatted}',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.info_outline, color: Colors.white54), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 24),
                // Action grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(context, Icons.notifications_outlined, AppStrings.setAsRingtone, () async {
                      Navigator.pop(context);
                      final success = await RingtoneService.setAsRingtone(song.path);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Ringtone set successfully' : 'Failed to set ringtone')),
                        );
                      }
                    }),
                    _actionButton(context, Icons.image_outlined, AppStrings.changeCover, () {
                      Navigator.pop(context);
                    }),
                    _actionButton(context, Icons.label_outline, AppStrings.editTags, () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => TagEditorScreen(song: song),
                      ));
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(context, Icons.album_outlined, AppStrings.goToAlbum, () {
                      Navigator.pop(context);
                    }),
                    _actionButton(context, Icons.visibility_off_outlined, AppStrings.hideSong, () {
                      context.read<MusicLibraryProvider>().hideSong(song.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Song hidden')),
                      );
                    }),
                    _actionButton(context, Icons.delete_outline, AppStrings.deleteFromDevice, () {
                      _showDeleteConfirmation(context);
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                // List options
                _listTile(Icons.speed_rounded, AppStrings.speed, onTap: () => _showSpeedDialog(context)),
                _listTile(Icons.tune_rounded, AppStrings.playbackSettings, subtitle: AppStrings.crossfadeGapless),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => SwitchListTile(
                    secondary: const Icon(Icons.brightness_low_rounded, color: Colors.white70),
                    title: Text(AppStrings.keepScreenOn, style: AppTextStyles.settingsTitle),
                    value: settings.keepScreenOn,
                    onChanged: (v) => settings.setKeepScreenOn(v),
                  ),
                ),
                _listTile(Icons.settings_outlined, AppStrings.settings),
                const SizedBox(height: 16),
                const Divider(color: AppColors.divider),
                // Volume
                _buildVolumeSection(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90, height: 80,
        decoration: BoxDecoration(
          color: AppColors.cardDarkLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10), textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _listTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: AppTextStyles.settingsTitle),
      subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.settingsSubtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }

  Widget _buildVolumeSection(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        return Column(
          children: [
            Row(
              children: [
                const Icon(Icons.volume_up_rounded, color: Colors.white70),
                Expanded(
                  child: Slider(
                    value: audio.volume,
                    onChanged: (v) => audio.setVolume(v),
                    activeColor: AppColors.accentOrange,
                  ),
                ),
                Text('${(audio.volume * 100).round()}%', style: AppTextStyles.bodySmall),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [125, 150, 175, 200].map((v) {
                return OutlinedButton(
                  onPressed: () => audio.setVolume(v / 100),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('$v%', style: AppTextStyles.bodySmall),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(AppStrings.confirm, style: AppTextStyles.headingSmall),
        content: Text('Delete "${song.displayTitle}" from device?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete feature requires MANAGE_EXTERNAL_STORAGE')),
              );
            },
            child: Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    final audio = context.read<AudioProvider>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(AppStrings.speed, style: AppTextStyles.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
            return ListTile(
              title: Text('${speed}x', style: AppTextStyles.bodyMedium),
              trailing: audio.speed == speed ? Icon(Icons.check, color: AppColors.accentOrange) : null,
              onTap: () {
                audio.setSpeed(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
