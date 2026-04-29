import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/music_library_provider.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import 'package:offline_music_player/services/storage_service.dart';
import '../utils/duration_formatter.dart';
import '../widgets/song_options_sheet.dart';
import '../widgets/glass_container.dart';
import 'lyrics_screen.dart';
import 'equalizer_screen.dart';
import 'sleep_timer_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: Consumer<AudioProvider>(
        builder: (context, audio, _) {
          final song = audio.currentSong;
          if (song == null) {
            return const Center(child: Text('No song playing', style: TextStyle(color: Colors.white54)));
          }

          return Stack(
            children: [
              // Dynamic Blurred Background
              Positioned.fill(
                child: QueryArtworkWidget(
                  id: song.id, type: ArtworkType.AUDIO,
                  artworkHeight: double.infinity, artworkWidth: double.infinity,
                  artworkBorder: BorderRadius.zero,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Container(color: AppColors.surfaceDark),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Foreground Content
              SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 160,
                            child: TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.white,
                              indicatorSize: TabBarIndicatorSize.label,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white54,
                              labelStyle: AppTextStyles.tabLabel,
                              dividerColor: Colors.transparent,
                              tabs: const [Tab(text: 'Song'), Tab(text: 'Lyrics')],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                            onPressed: () => SongOptionsSheet.show(context, song),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSongTab(context, audio, song),
                          LyricsScreen(songId: song.id, songTitle: song.displayTitle, songArtist: song.displayArtist),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSongTab(BuildContext context, AudioProvider audio, SongModel song) {
    final library = context.watch<MusicLibraryProvider>();
    final isFavorite = library.favorites.contains(song);

    return Column(
      children: [
        // Album art
        Expanded(
          flex: 4,
          child: Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkHeight: 260, artworkWidth: 260,
                  artworkFit: BoxFit.cover,
                  artworkBorder: BorderRadius.circular(20),
                  nullArtworkWidget: Container(
                    width: 260, height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFFFF6B9D), Color(0xFF6B8CFF)],
                      ),
                    ),
                    child: const Icon(Icons.music_note_rounded, size: 80, color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Song info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(song.displayTitle, style: AppTextStyles.playerTitle.copyWith(shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(song.displayArtist, style: AppTextStyles.playerArtist, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Controls Area with Glassmorphism
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GlassContainer(
              opacity: 0.15,
              borderRadius: 32,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Action buttons row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionIcon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          () => library.toggleFavorite(song.id),
                          color: isFavorite ? Colors.redAccent : Colors.white70,
                        ),
                        _actionIcon(Icons.playlist_add_rounded, () {}),
                        _actionIcon(Icons.equalizer_rounded, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const EqualizerScreen()));
                        }),
                        _actionIcon(Icons.timer_outlined, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTimerScreen()));
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Seek bar
                  StreamBuilder<PositionData>(
                    stream: audio.positionDataStream,
                    builder: (context, snapshot) {
                      final data = snapshot.data ?? PositionData(Duration.zero, Duration.zero, Duration.zero);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white12,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: data.position.inMilliseconds.toDouble().clamp(0, data.duration.inMilliseconds.toDouble()),
                                max: data.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                                onChanged: (v) => audio.seek(Duration(milliseconds: v.round())),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DurationFormatter.format(data.position), style: AppTextStyles.playerTime),
                                  Text(DurationFormatter.format(data.duration), style: AppTextStyles.playerTime),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Playback controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shuffle_rounded, size: 24,
                              color: audio.shuffleMode ? Colors.white : Colors.white38),
                          onPressed: () => audio.toggleShuffle(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 44, color: Colors.white),
                          onPressed: () => audio.playPrevious(),
                        ),
                        // Play/Pause button
                        StreamBuilder<bool>(
                          stream: audio.playerStateStream.map((s) => s.playing),
                          builder: (context, snapshot) {
                            final playing = snapshot.data ?? false;
                            return GestureDetector(
                              onTap: () => audio.togglePlayPause(),
                              child: Container(
                                width: 72, height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20),
                                  ],
                                ),
                                child: Icon(
                                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 44, color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 44, color: Colors.white),
                          onPressed: () => audio.playNext(),
                        ),
                        IconButton(
                          icon: Icon(
                            audio.repeatMode == AppConstants.repeatOne ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                            size: 24,
                            color: audio.repeatMode != AppConstants.repeatOff ? Colors.white : Colors.white38,
                          ),
                          onPressed: () => audio.toggleRepeat(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.white70, size: 26),
      onPressed: onTap,
    );
  }
}
