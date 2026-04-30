import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'providers/theme_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/music_library_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/equalizer_provider.dart';
import 'providers/lyrics_provider.dart';
import 'providers/sleep_timer_provider.dart';
import 'services/storage_service.dart';
import 'services/audio_handler.dart';
import 'screens/splash_screen.dart';
import 'main.dart'; // To access audioHandler global

class MusicPlayerApp extends StatefulWidget {
  const MusicPlayerApp({super.key});

  @override
  State<MusicPlayerApp> createState() => _MusicPlayerAppState();
}

class _MusicPlayerAppState extends State<MusicPlayerApp> {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Initialize Storage
    final storage = await StorageService.getInstance();

    // 2. Initialize Providers
    if (!mounted) return;
    await context.read<ThemeProvider>().init(storage);
    await context.read<MusicLibraryProvider>().init(storage); // Missing initialization added
    await context.read<AudioProvider>().init(storage);
    await context.read<PlaylistProvider>().init(storage);
    await context.read<SettingsProvider>().init(storage);
    await context.read<SearchProvider>().init(storage);
    await context.read<EqualizerProvider>().init(storage);
    await context.read<LyricsProvider>().init(storage);
    await context.read<SleepTimerProvider>().init(storage);

    // Connect sleep timer to audio
    if (!mounted) return;
    context.read<SleepTimerProvider>().setOnTimerEnd(() {
      context.read<AudioProvider>().pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While loading, just show a simple dark screen. 
          // This ensures we get past the Android white splash screen.
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF0D0B1E), // Primary Dark
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E1B35), // Card Dark
                      ),
                      child: const Icon(Icons.music_note_rounded, size: 50, color: Color(0xFFFF8C00)),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(color: Color(0xFFFF8C00)),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Failed to initialize app:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'Music Player',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.themeData,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
