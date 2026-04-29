import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/music_library_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import '../models/song_model.dart';

class HiddenMusicScreen extends StatefulWidget {
  const HiddenMusicScreen({super.key});

  @override
  State<HiddenMusicScreen> createState() => _HiddenMusicScreenState();
}

class _HiddenMusicScreenState extends State<HiddenMusicScreen> {
  bool _isAuthenticated = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() {
    final settings = context.read<SettingsProvider>();
    if (!settings.privacyLockEnabled || settings.privacyPin == null) {
      setState(() => _isAuthenticated = true);
    } else {
      _showPinDialog();
    }
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Enter PIN', style: AppTextStyles.headingSmall),
        content: TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter privacy PIN',
            hintStyle: TextStyle(color: Colors.white24),
          ),
          onSubmitted: (v) => _verifyPin(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // exit screen
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => _verifyPin(context),
            child: const Text('VERIFY'),
          ),
        ],
      ),
    );
  }

  void _verifyPin(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    if (_pinController.text == settings.privacyPin) {
      Navigator.pop(context);
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(backgroundColor: AppColors.surfaceDark);
    }

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
                    Text(AppStrings.hiddenMusic, style: AppTextStyles.headingMedium),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<MusicLibraryProvider>(
                  builder: (context, library, _) {
                    final hiddenSongs = library.hiddenSongs;
                    if (hiddenSongs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility_off_rounded, size: 64, color: Colors.white24),
                            const SizedBox(height: 16),
                            Text('No hidden songs', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: hiddenSongs.length,
                      itemBuilder: (context, index) {
                        final song = hiddenSongs[index];
                        return ListTile(
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.cardDarkLight,
                            ),
                            child: const Icon(Icons.music_note, color: Colors.white38),
                          ),
                          title: Text(song.displayTitle, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(song.displayArtist, style: AppTextStyles.songSubtitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_rounded, color: Colors.white54),
                                tooltip: AppStrings.unhide,
                                onPressed: () => library.unhideSong(song.id),
                              ),
                              IconButton(
                                icon: Icon(Icons.play_arrow_rounded, color: Theme.of(context).primaryColor),
                                onPressed: () => context.read<AudioProvider>().playSong(song),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
