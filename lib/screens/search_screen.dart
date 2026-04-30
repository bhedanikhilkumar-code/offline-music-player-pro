import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _showSuggestions = _searchController.text.isNotEmpty && _searchFocusNode.hasFocus;
      });
    });
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchController.text.isNotEmpty && _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      context.read<SearchProvider>().addToRecent(query);
    }
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          body: Container(
            decoration: themeProvider.backgroundDecoration,
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
                              focusNode: _searchFocusNode,
                              autofocus: true,
                              style: AppTextStyles.bodyMedium,
                              onChanged: _onSearch,
                              onSubmitted: _submitSearch,
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
                                          _searchFocusNode.requestFocus();
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
                  // Results / Suggestions
                  Expanded(
                    child: Consumer<SearchProvider>(
                      builder: (context, search, _) {
                        // Show suggestions overlay when typing
                        if (_showSuggestions && search.hasResults) {
                          return _buildSuggestions(search);
                        }
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
      },
    );
  }

  // ─── Search Suggestions ───
  Widget _buildSuggestions(SearchProvider search) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        children: [
          // Song suggestions
          if (search.songResults.isNotEmpty) ...[
            _suggestionSectionLabel('Songs', Icons.music_note_rounded),
            ...search.songResults.take(4).map((song) => _buildSongSuggestion(song)),
          ],
          // Album suggestions
          if (search.albumResults.isNotEmpty) ...[
            _suggestionSectionLabel('Albums', Icons.album_rounded),
            ...search.albumResults.take(3).map((album) => _buildAlbumSuggestion(album)),
          ],
          // Artist suggestions
          if (search.artistResults.isNotEmpty) ...[
            _suggestionSectionLabel('Artists', Icons.person_rounded),
            ...search.artistResults.take(3).map((artist) => _buildArtistSuggestion(artist)),
          ],
          // Playlist suggestions
          if (search.playlistResults.isNotEmpty) ...[
            _suggestionSectionLabel('Playlists', Icons.queue_music_rounded),
            ...search.playlistResults.take(3).map((playlist) => _buildPlaylistSuggestion(playlist)),
          ],
          // "View all results" button
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              onPressed: () {
                _submitSearch(_searchController.text);
              },
              icon: const Icon(Icons.search_rounded, size: 18),
              label: Text('View all results for "${_searchController.text}"'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _suggestionSectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongSuggestion(dynamic song) {
    final query = _searchController.text.toLowerCase();
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.cardDarkLight,
        ),
        child: const Icon(Icons.music_note_rounded, color: Colors.white38, size: 20),
      ),
      title: _highlightedText(song.title, query),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.north_west_rounded, color: Colors.white24, size: 16),
      onTap: () {
        final audio = context.read<AudioProvider>();
        final search = context.read<SearchProvider>();
        audio.playSong(song, playlist: search.songResults);
        _submitSearch(_searchController.text);
      },
    );
  }

  Widget _buildAlbumSuggestion(dynamic album) {
    final query = _searchController.text.toLowerCase();
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.cardDarkLight,
        ),
        child: const Icon(Icons.album_rounded, color: Colors.white38, size: 20),
      ),
      title: _highlightedText(album.displayName, query),
      subtitle: Text(
        '${album.displayArtist} • ${album.songCount} songs',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.north_west_rounded, color: Colors.white24, size: 16),
      onTap: () {
        _submitSearch(_searchController.text);
        Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)));
      },
    );
  }

  Widget _buildArtistSuggestion(dynamic artist) {
    final query = _searchController.text.toLowerCase();
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.cardDarkLight,
        child: Text(
          artist.displayName.isNotEmpty ? artist.displayName[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
        ),
      ),
      title: _highlightedText(artist.displayName, query),
      subtitle: Text(
        '${artist.songCount} songs',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: Icon(Icons.north_west_rounded, color: Colors.white24, size: 16),
      onTap: () {
        _submitSearch(_searchController.text);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistDetailScreen(artist: artist)));
      },
    );
  }

  Widget _buildPlaylistSuggestion(dynamic playlist) {
    final query = _searchController.text.toLowerCase();
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.cardDarkLight,
        ),
        child: const Icon(Icons.queue_music_rounded, color: Colors.white38, size: 20),
      ),
      title: _highlightedText(playlist.name, query),
      subtitle: Text(
        '${playlist.songCount} songs',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: Icon(Icons.north_west_rounded, color: Colors.white24, size: 16),
      onTap: () {
        _submitSearch(_searchController.text);
      },
    );
  }

  // Highlights matching text in suggestions
  Widget _highlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    final lowerText = text.toLowerCase();
    final matchIndex = lowerText.indexOf(query);
    if (matchIndex < 0) {
      return Text(text, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (matchIndex > 0)
            TextSpan(
              text: text.substring(0, matchIndex),
              style: AppTextStyles.songTitle,
            ),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: AppTextStyles.songTitle.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (matchIndex + query.length < text.length)
            TextSpan(
              text: text.substring(matchIndex + query.length),
              style: AppTextStyles.songTitle,
            ),
        ],
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
          trailing: const Icon(Icons.north_west_rounded, color: Colors.white24, size: 16),
          onTap: () {
            _searchController.text = q;
            _searchController.selection = TextSelection.fromPosition(TextPosition(offset: q.length));
            _onSearch(q);
            _submitSearch(q);
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
