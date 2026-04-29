import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';
import '../models/playlist_model.dart';

class PlaylistTile extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;

  const PlaylistTile({super.key, required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.cardDarkLight,
        ),
        child: Icon(Icons.queue_music_rounded, color: Theme.of(context).primaryColor),
      ),
      title: Text(playlist.name, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${playlist.songCount} songs', style: AppTextStyles.songSubtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}
