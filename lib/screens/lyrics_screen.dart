import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/lyrics_provider.dart';

class LyricsScreen extends StatefulWidget {
  final int songId;
  final String songTitle;
  final String songArtist;
  const LyricsScreen({super.key, required this.songId, required this.songTitle, required this.songArtist});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LyricsProvider>(
      builder: (context, lyricsProvider, _) {
        final lyrics = lyricsProvider.getLyrics(widget.songId);

        if (lyrics != null && lyrics.isNotEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.songTitle, style: AppTextStyles.headingMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(widget.songArtist, style: AppTextStyles.playerArtist),
                const SizedBox(height: 24),
                Text(lyrics, style: AppTextStyles.bodyMedium.copyWith(height: 2)),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => _showEditLyricsDialog(context, lyricsProvider, lyrics),
                    child: const Text('Edit Lyrics'),
                  ),
                ),
              ],
            ),
          );
        }

        // No lyrics - show options
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(widget.songTitle, style: AppTextStyles.headingMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(widget.songArtist, style: AppTextStyles.playerArtist),
              const SizedBox(height: 48),
              // Illustration placeholder
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lyrics_outlined, size: 56, color: Colors.white38),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.selectWayToGetLyrics, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
              const SizedBox(height: 32),

              // Select lyrics version
              _optionButton(
                icon: Icons.queue_music_rounded,
                label: AppStrings.selectLyricsVersion,
                color: AppColors.accentOrange,
                filled: true,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              // Search online (disabled for offline)
              _optionButton(
                icon: Icons.search_rounded,
                label: AppStrings.searchOnline,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Online search not available in offline mode')),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Add local lyrics
              _optionButton(
                icon: Icons.add_circle_outline,
                label: AppStrings.addLocalLyrics,
                onTap: () => _pickLyricsFile(context, lyricsProvider),
              ),
              const SizedBox(height: 12),
              // Enter lyrics
              _optionButton(
                icon: Icons.edit_outlined,
                label: AppStrings.enterLyrics,
                onTap: () => _showEditLyricsDialog(context, lyricsProvider, ''),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _optionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool filled = false,
  }) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 22),
              label: Text(label, style: AppTextStyles.buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? AppColors.accentOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 22, color: Colors.white70),
              label: Text(label, style: AppTextStyles.bodyMedium),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
            ),
    );
  }

  Future<void> _pickLyricsFile(BuildContext context, LyricsProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['lrc', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        await provider.saveLyrics(widget.songId, content);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lyrics: $e')),
        );
      }
    }
  }

  void _showEditLyricsDialog(BuildContext context, LyricsProvider provider, String existing) {
    final controller = TextEditingController(text: existing);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(AppStrings.enterLyrics, style: AppTextStyles.headingSmall),
        content: SizedBox(
          height: 300,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Type lyrics here...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              provider.saveLyrics(widget.songId, controller.text);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
