import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';
import 'providers/audio_provider.dart';
import 'providers/music_library_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/equalizer_provider.dart';
import 'providers/lyrics_provider.dart';
import 'providers/sleep_timer_provider.dart';
import 'app.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AudioHandler
  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.bhedanikhilkumar.musicplayer.playback',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationChannelDescription:
          'Controls for the music currently playing',
      androidNotificationIcon: 'drawable/ic_notification',
      notificationColor: Color(0xFFFF6B35),
      androidShowNotificationBadge: true,
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0B1E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => MusicLibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => EqualizerProvider()),
        ChangeNotifierProvider(create: (_) => LyricsProvider()),
        ChangeNotifierProvider(create: (_) => SleepTimerProvider()),
      ],
      child: const MusicPlayerApp(),
    ),
  );
}
