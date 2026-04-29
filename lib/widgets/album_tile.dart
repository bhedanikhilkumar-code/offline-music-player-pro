import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';
import '../models/album_model.dart';

class AlbumTile extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onTap;

  const AlbumTile({super.key, required this.album, required this.onTap});

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
        child: const Icon(Icons.album_rounded, color: Colors.white38),
      ),
      title: Text(album.displayName, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${album.displayArtist} | ${album.songCount} songs', style: AppTextStyles.songSubtitle),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded, color: Colors.white54, size: 22),
        onPressed: () {},
      ),
    );
  }
}
