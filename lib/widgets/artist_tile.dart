import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';
import '../models/artist_model.dart';

class ArtistTile extends StatelessWidget {
  final ArtistModel artist;
  final VoidCallback onTap;

  const ArtistTile({super.key, required this.artist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.cardDarkLight,
        child: Text(artist.displayName[0].toUpperCase(), style: AppTextStyles.bodyLarge),
      ),
      title: Text(artist.displayName, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${artist.songCount} songs • ${artist.albumCount} albums', style: AppTextStyles.songSubtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}
