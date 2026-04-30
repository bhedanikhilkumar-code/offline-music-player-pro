import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/music_library_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'package:on_audio_query/on_audio_query.dart' as on_audio_query
    hide SongModel;

class TagEditorScreen extends StatefulWidget {
  final SongModel song;
  const TagEditorScreen({super.key, required this.song});

  @override
  State<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends State<TagEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
    _albumController = TextEditingController(text: widget.song.album);
    // Year and genre might not be in our SongModel, we'll try to fetch them from the file
    _yearController = TextEditingController();
    _genreController = TextEditingController();
    _fetchFullTags();
  }

  Future<void> _fetchFullTags() async {
    try {
      final tags = await AudioTags.read(widget.song.path);
      if (tags != null) {
        setState(() {
          if (tags.year != null) _yearController.text = tags.year.toString();
          if (tags.genre != null) _genreController.text = tags.genre!;
        });
      }
    } catch (e) {
      debugPrint("Error reading tags: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _saveTags() async {
    setState(() => _isSaving = true);
    try {
      final tags = Tag(
        title: _titleController.text,
        trackArtist: _artistController.text,
        album: _albumController.text,
        year: int.tryParse(_yearController.text),
        genre: _genreController.text,
        pictures: [],
      );

      await AudioTags.write(widget.song.path, tags);

      if (mounted) {
        final updatedSong = SongModel(
          id: widget.song.id,
          title: _titleController.text,
          artist: _artistController.text,
          album: _albumController.text,
          duration: widget.song.duration,
          path: widget.song.path,
          uri: widget.song.uri,
          dateAdded: widget.song.dateAdded,
          size: widget.song.size,
          albumArtPath: widget.song.albumArtPath,
          albumId: widget.song.albumId,
        );

        context.read<MusicLibraryProvider>().updateSong(updatedSong);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tags updated successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving tags: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Tags'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                TextButton(
                  onPressed: _saveTags,
                  child: Text('SAVE',
                      style: TextStyle(
                          color: themeProvider.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: themeProvider.backgroundDecoration,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Artwork Preview
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: on_audio_query.QueryArtworkWidget(
                            id: widget.song.id,
                            type: on_audio_query.ArtworkType.AUDIO,
                            artworkWidth: 160,
                            artworkHeight: 160,
                            nullArtworkWidget: Container(
                              color: AppColors.cardDarkLight,
                              child: const Icon(Icons.music_note,
                                  color: Colors.white24, size: 64),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField('Title', _titleController),
                    const SizedBox(height: 20),
                    _buildTextField('Artist', _artistController),
                    const SizedBox(height: 20),
                    _buildTextField('Album', _albumController),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField('Year', _yearController,
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 20),
                        Expanded(
                            child: _buildTextField('Genre', _genreController)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Note: Saving tags modifies the music file directly. Some players might take time to reflect changes.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    final primaryColor = context.read<ThemeProvider>().primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: primaryColor)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor)),
          ),
        ),
      ],
    );
  }
}
