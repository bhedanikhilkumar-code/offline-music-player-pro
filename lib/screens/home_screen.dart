import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:on_audio_query/on_audio_query.dart' as on_audio_query hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/audio_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/playlist_provider.dart';
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerMenu(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.surfaceDark, AppColors.primaryDark],
          ),
        ),
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
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 28), // Hamburger menu variant
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.app_shortcut_rounded, color: Colors.white70),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      labelStyle: AppTextStyles.headingMedium.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTextStyles.headingMedium.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: AppStrings.songs),
        Tab(text: AppStrings.playlists),
        Tab(text: AppStrings.folders),
        Tab(text: AppStrings.albums),
        Tab(text: AppStrings.artists),
      ],
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

        return Column(
          children: [
            // Header with count, sort, list view
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('${songs.length} Songs', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
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
                  const SizedBox(width: 8),
                  const Icon(Icons.format_list_bulleted_rounded, color: Colors.white70, size: 22),
                ],
              ),
            ),
            // Shuffle & Play Pill Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final shuffled = List.from(songs)..shuffle();
                        context.read<AudioProvider>().setQueue(shuffled.cast(), startIndex: 0);
                      },
                      icon: const Icon(Icons.shuffle_rounded, color: AppColors.accentOrange, size: 20),
                      label: Text('Shuffle', style: AppTextStyles.buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardDarkLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (songs.isNotEmpty) {
                          context.read<AudioProvider>().playSong(songs.first, playlist: songs, index: 0);
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: AppColors.accentOrange, size: 20),
                      label: Text('Play', style: AppTextStyles.buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardDarkLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildRecentlyPlayed(library),
            _buildMostPlayed(library),
            const SizedBox(height: 8),
            // Song list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Consumer<AudioProvider>(
                    builder: (context, audio, _) {
                      return SongTile(
                        song: song,
                        isPlaying: audio.currentSong?.id == song.id,
                        onTap: () => audio.playSong(song, playlist: songs, index: index),
                        onOptionsTap: () => SongOptionsSheet.show(context, song),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaylistsTab() {
    final library = context.watch<MusicLibraryProvider>();
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, _) {
        final playlists = playlistProvider.playlists;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showCreatePlaylistDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(AppStrings.createPlaylist, style: AppTextStyles.bodyMedium),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildSmartPlaylistTile(
                    context,
                    title: 'Recently Played',
                    icon: Icons.history_rounded,
                    color: AppColors.accentOrange,
                    songCount: library.recentlyPlayed.length,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistId: 'recent', customSongs: library.recentlyPlayed, title: 'Recently Played'),
                    )),
                  ),
                  _buildSmartPlaylistTile(
                    context,
                    title: 'Most Played',
                    icon: Icons.trending_up_rounded,
                    color: Colors.blueAccent,
                    songCount: library.mostPlayed.length,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistId: 'most_played', customSongs: library.mostPlayed, title: 'Most Played'),
                    )),
                  ),
                  _buildSmartPlaylistTile(
                    context,
                    title: 'Favorites',
                    icon: Icons.favorite_rounded,
                    color: Colors.pinkAccent,
                    songCount: library.favorites.length,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistId: 'favorites', customSongs: library.favorites, title: 'Favorites'),
                    )),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Colors.white10),
                  ),
                  if (playlists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: Text('No custom playlists yet', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38))),
                    )
                  else
                    ...playlists.map((playlist) => ListTile(
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.cardDarkLight,
                            ),
                            child: Icon(Icons.queue_music_rounded, color: Theme.of(context).primaryColor),
                          ),
                          title: Text(playlist.name, style: AppTextStyles.songTitle),
                          subtitle: Text('${playlist.songCount} songs', style: AppTextStyles.songSubtitle),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                          )),
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
          itemBuilder: (context, index) {
            final folder = folders[index];
            return ListTile(
              leading: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.cardDarkLight,
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
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.cardDark,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.themeColors[index % AppColors.themeColors.length].withOpacity(0.3),
                                AppColors.cardDark,
                              ],
                            ),
                          ),
                          child: const Icon(Icons.album_rounded, size: 48, color: Colors.white38),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(album.displayName, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${album.displayArtist} | ${album.songCount} songs',
                            style: AppTextStyles.songSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildRecentlyPlayed(MusicLibraryProvider library) {
    final recent = library.recentlyPlayed;
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.accentOrange, size: 20),
              const SizedBox(width: 8),
              Text('Recently Played', style: AppTextStyles.headingSmall.copyWith(fontSize: 18)),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              return _buildRecentSongItem(context, recent[index], recent);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMostPlayed(MusicLibraryProvider library) {
    final mostPlayed = library.mostPlayed;
    if (mostPlayed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text('Most Played', style: AppTextStyles.headingSmall.copyWith(fontSize: 18)),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: mostPlayed.length,
            itemBuilder: (context, index) {
              return _buildRecentSongItem(context, mostPlayed[index], mostPlayed);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(color: Colors.white10),
        ),
      ],
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
