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

  // Phase 1: Only theme (instant — from SharedPreferences)
  late Future<void> _themeFuture;
  // Phase 2: Everything else (runs in background)
  Future<void>? _restFuture;

  @override
  void initState() {
    super.initState();
    _themeFuture = _initTheme();
  }

  /// Phase 1 — load ONLY theme. Super fast (just SharedPreferences reads).
  Future<void> _initTheme() async {
    final storage = await StorageService.getInstance();
    if (!mounted) return;
    await context.read<ThemeProvider>().init(storage);

    // Immediately kick off Phase 2 in background (don't await)
    _restFuture = _initRestOfApp(storage);
  }

  /// Phase 2 — everything else. Runs while SplashScreen is showing.
  Future<void> _initRestOfApp(StorageService storage) async {
    if (!mounted) return;

    // Run heavy providers concurrently where possible
    await Future.wait([
      context.read<SettingsProvider>().init(storage),
      context.read<SearchProvider>().init(storage),
      context.read<EqualizerProvider>().init(storage),
      context.read<LyricsProvider>().init(storage),
      context.read<SleepTimerProvider>().init(storage),
    ]);

    if (!mounted) return;

    // Audio + Playlist can run concurrently
    await Future.wait([
      context.read<AudioProvider>().init(storage),
      context.read<PlaylistProvider>().init(storage),
    ]);

    if (!mounted) return;

    // MusicLibrary scans files — do last
    await context.read<MusicLibraryProvider>().init(storage);

    // Connect sleep timer to audio
    if (!mounted) return;
    context.read<SleepTimerProvider>().setOnTimerEnd(() {
      context.read<AudioProvider>().pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _themeFuture,
      builder: (context, snapshot) {
        // While theme is loading (< 50ms typically), show plain dark screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF0D0B1E),
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

        // Theme is ready — show full app with user's saved theme immediately
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'Music Player',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.themeData,
              home: SplashScreen(restFuture: _restFuture),
            );
          },
        );
      },
    );
  }
}
