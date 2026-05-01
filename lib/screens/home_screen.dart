import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart' as on_audio_query hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/theme_provider.dart';
import '../models/song_model.dart';
import 'package:offline_music_player/services/storage_service.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_sheet.dart';
import '../widgets/drawer_menu.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'theme_screen.dart';
import 'playlist_detail_screen.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';
import 'folder_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _initialized = false;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initLibrary();
  }

  Future<void> _initLibrary() async {
    if (_initialized) return;
    final storage = await StorageService.getInstance();
    if (!mounted) return;
    await context.read<MusicLibraryProvider>().init(storage);
    _initialized = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPress != null && now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
          Navigator.of(context).pop();
          return;
        }
        _lastBackPress = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Scaffold(
            key: _scaffoldKey,
            drawer: const DrawerMenu(),
            body: Container(
              decoration: themeProvider.backgroundDecoration,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSongsTab(),
                          _buildPlaylistsTab(),
                          _buildFoldersTab(),
                          _buildAlbumsTab(),
                          _buildArtistsTab(),
                        ],
                      ),
                    ),
                    const MiniPlayer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Text('Player Pro', style: AppTextStyles.headingMedium.copyWith(letterSpacing: 1.2)),
          const Spacer(),
          _buildAppBarAction(Icons.search_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
          const SizedBox(width: 12),
          _buildAppBarAction(Icons.app_shortcut_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen()))),
        ],
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.accentOrange,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentOrange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.normal, fontSize: 14),
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(AppStrings.songs))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(AppStrings.playlists))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(AppStrings.folders))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(AppStrings.albums))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(AppStrings.artists))),
        ],
      ),
    );
  }

  Widget _buildSongsTab() {
    return Consumer<MusicLibraryProvider>(
      builder: (context, library, _) {
        if (library.isLoading) {
          return const Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Scanning music...', style: TextStyle(color: Colors.white54)),
            ],
          ));
        }

        final songs = library.allSongs;
        if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.music_off_rounded, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(AppStrings.noSongsFound, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)),
              ],
            ),
          );
        }

        final recent = library.recentlyPlayed;
        final mostPlayed = library.mostPlayed;

        return CustomScrollView(
          slivers: [
            // ─── Sort bar ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.library_music_rounded, color: Colors.white54, size: 16),
                          const SizedBox(width: 6),
                          Text('${songs.length} Songs', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.swap_vert_rounded, color: Colors.white70, size: 22),
                      color: AppColors.cardDark,
                      onSelected: (value) => library.setSortType(value),
                      itemBuilder: (_) => [
                        _sortMenuItem('Title', 'title', library.sortType),
                        _sortMenuItem('Artist', 'artist', library.sortType),
                        _sortMenuItem('Album', 'album', library.sortType),
                        _sortMenuItem('Duration', 'duration', library.sortType),
                        _sortMenuItem('Date', 'date', library.sortType),
                        _sortMenuItem('Size', 'size', library.sortType),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Shuffle & Play buttons ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.shuffle_rounded,
                        label: 'Shuffle',
                        gradient: const [Color(0xFFFF6B35), Color(0xFFFF8F65)],
                        onTap: () {
                          final shuffled = List.from(songs)..shuffle();
                          context.read<AudioProvider>().setQueue(shuffled.cast(), startIndex: 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Play All',
                        gradient: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                        onTap: () {
                          if (songs.isNotEmpty) {
                            context.read<AudioProvider>().playSong(songs.first, playlist: songs, index: 0);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Recently Played (horizontal cards) ───
            if (recent.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history_rounded, color: AppColors.accentOrange, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('Recently Played', style: AppTextStyles.headingSmall.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${recent.length}', style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 165,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: recent.length,
                    itemBuilder: (context, index) => _buildRecentSongItem(context, recent[index], recent),
                  ),
                ),
              ),
            ],

            // ─── Most Played (horizontal cards) ───
            if (mostPlayed.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.blueAccent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('Most Played', style: AppTextStyles.headingSmall.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${mostPlayed.length}', style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 165,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: mostPlayed.length,
                    itemBuilder: (context, index) => _buildRecentSongItem(context, mostPlayed[index], mostPlayed),
                  ),
                ),
              ),
            ],

            // ─── All Songs Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.queue_music_rounded, color: Colors.purpleAccent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('All Songs', style: AppTextStyles.headingSmall.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${songs.length}', style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
                  ],
                ),
              ),
            ),

            // ─── All Songs List ───
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  return _OneShotListAnimation(
                    index: index,
                    child: Consumer<AudioProvider>(
                      builder: (context, audio, _) {
                        return SongTile(
                          song: song,
                          isPlaying: audio.currentSong?.id == song.id,
                          onTap: () => audio.playSong(song, playlist: songs, index: index),
                          onOptionsTap: () => SongOptionsSheet.show(context, song),
                        );
                      },
                    ),
                  );
                },
                childCount: songs.length,
              ),
            ),

            // Bottom padding for MiniPlayer
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return Consumer2<PlaylistProvider, MusicLibraryProvider>(
      builder: (context, playlistProvider, library, _) {
        final playlists = playlistProvider.playlists;

        return Column(
          children: [
            // ─── Create Playlist Button ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showCreatePlaylistDialog(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.35)),
                      borderRadius: BorderRadius.circular(14),
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: Theme.of(context).primaryColor, size: 22),
                        const SizedBox(width: 8),
                        Text(AppStrings.createPlaylist,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  // ─── Smart Playlists Section Header ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
                    child: Text('SMART PLAYLISTS',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white24,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  _buildSmartPlaylistTile(context,
                    title: 'Recently Played',
                    icon: Icons.history_rounded,
                    color: AppColors.accentOrange,
                    songCount: library.recentlyPlayed.length,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistId: 'recent', customSongs: library.recentlyPlayed, title: 'Recently Played'),
                    )),
                  ),
                  _buildSmartPlaylistTile(context,
                    title: 'Most Played',
                    icon: Icons.trending_up_rounded,
                    color: Colors.blueAccent,
                    songCount: library.mostPlayed.length,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistId: 'most_played', customSongs: library.mostPlayed, title: 'Most Played'),
                    )),
                  ),
                  _buildSmartPlaylistTile(context,
                    title: 'Favorites',
                    icon: Icons.favorite_rounded,
                    color: Colors.pinkAccent,
                    songCount: library.favorites.length,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistId: 'favorites', customSongs: library.favorites, title: 'Favorites'),
                    )),
                  ),

                  // ─── Custom Playlists Section ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
                    child: Row(
                      children: [
                        Text('MY PLAYLISTS',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white24,
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${playlists.length}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (playlists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
                      child: Column(
                        children: [
                          Icon(Icons.library_music_rounded, size: 48, color: Colors.white12),
                          const SizedBox(height: 12),
                          Text('No playlists yet',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)),
                          const SizedBox(height: 4),
                          Text('Tap + above to create one',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white24)),
                        ],
                      ),
                    )
                  else
                    ...playlists.map((playlist) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                          )),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white.withOpacity(0.04),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).primaryColor.withOpacity(0.3),
                                        Theme.of(context).primaryColor.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(Icons.queue_music_rounded, color: Theme.of(context).primaryColor, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(playlist.name, style: AppTextStyles.songTitle, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text('${playlist.songCount} songs',
                                        style: AppTextStyles.songSubtitle.copyWith(color: Colors.white38)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoldersTab() {
    return Consumer<MusicLibraryProvider>(
      builder: (context, library, _) {
        final folders = library.folders;
        if (folders.isEmpty) {
          return Center(child: Text('No folders found', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)));
        }
        return ListView.builder(
          itemCount: folders.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final folder = folders[index];
            return ListTile(
              leading: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder_rounded, color: AppColors.accentAmber),
              ),
              title: Text(folder.name, style: AppTextStyles.songTitle),
              subtitle: Text('${folder.songCount} songs', style: AppTextStyles.songSubtitle),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FolderDetailScreen(folder: folder),
              )),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    return Consumer<MusicLibraryProvider>(
      builder: (context, library, _) {
        final albums = library.albums;
        if (albums.isEmpty) {
          return Center(child: Text('No albums found', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)));
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => AlbumDetailScreen(album: album),
              )),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: SizedBox(
                          width: double.infinity,
                          child: on_audio_query.QueryArtworkWidget(
                            id: album.id,
                            type: on_audio_query.ArtworkType.ALBUM,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.themeColors[index % AppColors.themeColors.length].withOpacity(0.3),
                                    Colors.black26,
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.album_rounded, size: 64, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(album.displayName, style: AppTextStyles.songTitle.copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text('${album.displayArtist}',
                                  style: AppTextStyles.songSubtitle.copyWith(fontSize: 12, color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${album.songCount}', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArtistsTab() {
    return Consumer<MusicLibraryProvider>(
      builder: (context, library, _) {
        final artists = library.artists;
        if (artists.isEmpty) {
          return Center(child: Text('No artists found', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)));
        }
        return ListView.builder(
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.themeColors[index % AppColors.themeColors.length].withOpacity(0.3),
                child: Text(
                  artist.displayName[0].toUpperCase(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.themeColors[index % AppColors.themeColors.length],
                  ),
                ),
              ),
              title: Text(artist.displayName, style: AppTextStyles.songTitle),
              subtitle: Text('${artist.songCount} songs • ${artist.albumCount} albums', style: AppTextStyles.songSubtitle),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ArtistDetailScreen(artist: artist),
              )),
            );
          },
        );
      },
    );
  }




  Widget _buildRecentSongItem(BuildContext context, SongModel song, List<SongModel> playlist) {
    return GestureDetector(
      onTap: () => context.read<AudioProvider>().playSong(song, playlist: playlist),
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  on_audio_query.QueryArtworkWidget(
                    id: song.id, type: on_audio_query.ArtworkType.AUDIO,
                    artworkWidth: 120, artworkHeight: 120,
                    artworkBorder: BorderRadius.zero,
                    nullArtworkWidget: Container(
                      width: 120, height: 120,
                      color: AppColors.cardDarkLight,
                      child: const Icon(Icons.music_note, color: Colors.white24, size: 40),
                    ),
                  ),
                  Positioned(
                    bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(song.displayTitle, style: AppTextStyles.songTitle.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(song.displayArtist, style: AppTextStyles.songSubtitle.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _sortMenuItem(String label, String value, String current) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          if (current == value) Icon(Icons.check, color: Theme.of(context).primaryColor, size: 18),
        ],
      ),
    );
  }

  Widget _buildSmartPlaylistTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required int songCount,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: AppTextStyles.songTitle),
      subtitle: Text('$songCount songs', style: AppTextStyles.songSubtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(AppStrings.createPlaylist, style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: AppStrings.playlistName,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<PlaylistProvider>().createPlaylist(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text(AppStrings.create),
          ),
        ],
      ),
    );
  }
}

/// A one-shot list item animation that plays only once per item.
/// On reverse scroll, items appear instantly without re-animating.
class _OneShotListAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const _OneShotListAnimation({
    required this.index,
    required this.child,
  });

  @override
  State<_OneShotListAnimation> createState() => _OneShotListAnimationState();
}

class _OneShotListAnimationState extends State<_OneShotListAnimation>
    with SingleTickerProviderStateMixin {
  static final Set<int> _animatedIndices = {};
  late final bool _shouldAnimate;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _shouldAnimate = !_animatedIndices.contains(widget.index);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(curve);

    if (_shouldAnimate) {
      // Stagger delay based on index (max 8 items stagger, then instant)
      final staggerDelay = (widget.index % 8) * 50;
      Future.delayed(Duration(milliseconds: staggerDelay), () {
        if (mounted) {
          _controller.forward();
          _animatedIndices.add(widget.index);
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldAnimate) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
