import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import 'package:intl/intl.dart';
import '../constants/app_text_styles.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onOptionsTap;
  final bool isPlaying;
  final int? index;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onOptionsTap,
    this.isPlaying = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Format date added as MM-dd
    final dateAdded = DateTime.fromMillisecondsSinceEpoch((song.dateAdded > 0 ? song.dateAdded : DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000);
    final dateStr = DateFormat('MM-dd').format(dateAdded);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF252344),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            artworkHeight: 52, artworkWidth: 52,
            artworkFit: BoxFit.cover,
            artworkBorder: BorderRadius.circular(12),
            nullArtworkWidget: const Center(
              child: Icon(Icons.music_note_rounded, color: Colors.white38, size: 28),
            ),
          ),
        ),
      ),
      title: Text(
        song.displayTitle,
        style: AppTextStyles.songTitle.copyWith(
          color: isPlaying ? const Color(0xFFFFD700) : Colors.white, // Yellow for playing song
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${song.displayArtist} - Music 🎶',
          style: AppTextStyles.songSubtitle.copyWith(color: Colors.white54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(dateStr, style: AppTextStyles.songSubtitle.copyWith(color: Colors.white38, fontSize: 11)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white54, size: 22),
            onPressed: onOptionsTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
