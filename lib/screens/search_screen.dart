import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/search_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_sheet.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final library = context.read<MusicLibraryProvider>();
    final playlists = context.read<PlaylistProvider>();
    context.read<SearchProvider>().search(
      query,
      songs: library.allSongs,
      albums: library.albums,
      artists: library.artists,
      playlists: playlists.playlists,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: AppTextStyles.bodyMedium,
                          onChanged: _onSearch,
                          onSubmitted: (q) {
                            if (q.isNotEmpty) context.read<SearchProvider>().addToRecent(q);
                          },
                          decoration: InputDecoration(
                            hintText: AppStrings.searchInLibrary,
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white38, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<SearchProvider>().clearSearch();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: AppTextStyles.tabLabel,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: AppStrings.all),
                  Tab(text: AppStrings.songs),
                  Tab(text: AppStrings.albums),
                  Tab(text: AppStrings.artists),
                  Tab(text: 'Playlist'),
                ],
              ),
              // Results
              Expanded(
                child: Consumer<SearchProvider>(
                  builder: (context, search, _) {
                    if (search.query.isEmpty) {
                      return _buildRecentSearches(search);
                    }
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllResults(search),
                        _buildSongResults(search),
                        _buildAlbumResults(search),
                        _buildArtistResults(search),
                        _buildPlaylistResults(search),
                      ],
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

  Widget _buildRecentSearches(SearchProvider search) {
    if (search.recentSearches.isEmpty) {
      return Center(child: Text('Start typing to search', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)));
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppStrings.recentSearches, style: AppTextStyles.sectionHeader),
        ),
        ...search.recentSearches.map((q) => ListTile(
          leading: const Icon(Icons.history, color: Colors.white38),
          title: Text(q, style: AppTextStyles.bodyMedium),
          onTap: () {
            _searchController.text = q;
            _onSearch(q);
          },
        )),
      ],
    );
  }

  Widget _buildAllResults(SearchProvider search) {
    if (!search.hasResults) {
      return Center(child: Text(AppStrings.noResults, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38)));
    }
    return ListView(
      children: [
        if (search.songResults.isNotEmpty) ...[
          _sectionHeader(AppStrings.songs, search.songResults.length),
          ...search.songResults.take(5).map((song) => Consumer<AudioProvider>(
            builder: (context, audio, _) => SongTile(
              song: song,
              isPlaying: audio.currentSong?.id == song.id,
              onTap: () => audio.playSong(song, playlist: search.songResults),
              onOptionsTap: () => SongOptionsSheet.show(context, song),
            ),
          )),
        ],
        if (search.albumResults.isNotEmpty) ...[
          _sectionHeader(AppStrings.albums, search.albumResults.length),
          ...search.albumResults.take(3).map((album) => ListTile(
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.cardDarkLight),
              child: const Icon(Icons.album_rounded, color: Colors.white38),
            ),
            title: Text(album.displayName, style: AppTextStyles.songTitle),
            subtitle: Text('${album.displayArtist} | ${album.songCount} songs', style: AppTextStyles.songSubtitle),
            trailing: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album))),
          )),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          const Spacer(),
          if (count > 5) TextButton(
            onPressed: () {},
            child: Text(AppStrings.viewAll, style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSongResults(SearchProvider search) {
    if (search.songResults.isEmpty) return Center(child: Text(AppStrings.noResults, style: TextStyle(color: Colors.white38)));
    return ListView.builder(
      itemCount: search.songResults.length,
      itemBuilder: (context, index) {
        final song = search.songResults[index];
        return Consumer<AudioProvider>(
          builder: (context, audio, _) => SongTile(
            song: song, isPlaying: audio.currentSong?.id == song.id,
            onTap: () => audio.playSong(song, playlist: search.songResults, index: index),
            onOptionsTap: () => SongOptionsSheet.show(context, song),
          ),
        );
      },
    );
  }

  Widget _buildAlbumResults(SearchProvider search) {
    if (search.albumResults.isEmpty) return Center(child: Text(AppStrings.noResults, style: TextStyle(color: Colors.white38)));
    return ListView.builder(
      itemCount: search.albumResults.length,
      itemBuilder: (context, index) {
        final album = search.albumResults[index];
        return ListTile(
          leading: Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.cardDarkLight), child: const Icon(Icons.album, color: Colors.white38)),
          title: Text(album.displayName, style: AppTextStyles.songTitle),
          subtitle: Text('${album.displayArtist} | ${album.songCount} songs', style: AppTextStyles.songSubtitle),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album))),
        );
      },
    );
  }

  Widget _buildArtistResults(SearchProvider search) {
    if (search.artistResults.isEmpty) return Center(child: Text(AppStrings.noResults, style: TextStyle(color: Colors.white38)));
    return ListView.builder(
      itemCount: search.artistResults.length,
      itemBuilder: (context, index) {
        final artist = search.artistResults[index];
        return ListTile(
          leading: CircleAvatar(backgroundColor: AppColors.cardDarkLight, child: Text(artist.displayName[0].toUpperCase())),
          title: Text(artist.displayName, style: AppTextStyles.songTitle),
          subtitle: Text('${artist.songCount} songs', style: AppTextStyles.songSubtitle),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistDetailScreen(artist: artist))),
        );
      },
    );
  }

  Widget _buildPlaylistResults(SearchProvider search) {
    if (search.playlistResults.isEmpty) return Center(child: Text(AppStrings.noResults, style: TextStyle(color: Colors.white38)));
    return ListView.builder(
      itemCount: search.playlistResults.length,
      itemBuilder: (context, index) {
        final playlist = search.playlistResults[index];
        return ListTile(
          leading: Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.cardDarkLight), child: const Icon(Icons.queue_music, color: Colors.white38)),
          title: Text(playlist.name, style: AppTextStyles.songTitle),
          subtitle: Text('${playlist.songCount} songs', style: AppTextStyles.songSubtitle),
        );
      },
    );
  }
}
