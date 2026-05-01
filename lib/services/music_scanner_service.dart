import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart'
    hide SongModel, AlbumModel, ArtistModel, PlaylistModel;
import '../models/song_model.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';

class MusicScannerService {
  static final OnAudioQuery _audioQuery = OnAudioQuery();

  static Future<List<SongModel>> scanSongs() async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      return songs
          .where((s) => s.duration != null && s.duration! > 0)
          .map((s) => SongModel(
                id: s.id,
                title: s.title,
                artist: s.artist ?? '<unknown>',
                album: s.album ?? 'Unknown Album',
                duration: s.duration ?? 0,
                path: s.data,
                uri: s.uri,
                dateAdded: s.dateAdded ?? 0,
                size: s.size,
                albumId: s.albumId,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error scanning songs: $e');
      return [];
    }
  }

  static Future<List<AlbumModel>> scanAlbums() async {
    try {
      final albums = await _audioQuery.queryAlbums(
        sortType: AlbumSortType.ALBUM,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      return albums
          .map((a) => AlbumModel(
                id: a.id,
                name: a.album,
                artist: a.artist ?? '<unknown>',
                songCount: a.numOfSongs,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error scanning albums: $e');
      return [];
    }
  }

  static Future<List<ArtistModel>> scanArtists() async {
    try {
      final artists = await _audioQuery.queryArtists(
        sortType: ArtistSortType.ARTIST,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      return artists
          .map((a) => ArtistModel(
                id: a.id,
                name: a.artist,
                songCount: a.numberOfTracks ?? 0,
                albumCount: a.numberOfAlbums ?? 0,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error scanning artists: $e');
      return [];
    }
  }

  static Future<List<SongModel>> getSongsForAlbum(int albumId) async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );
      return songs
          .where((s) =>
              s.albumId == albumId && s.duration != null && s.duration! > 0)
          .map((s) => SongModel(
                id: s.id,
                title: s.title,
                artist: s.artist ?? '<unknown>',
                album: s.album ?? 'Unknown Album',
                duration: s.duration ?? 0,
                path: s.data,
                uri: s.uri,
                dateAdded: s.dateAdded ?? 0,
                size: s.size,
                albumId: s.albumId,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<SongModel>> getSongsForArtist(int artistId) async {
    try {
      final songs = await _audioQuery.queryAudiosFrom(
        AudiosFromType.ARTIST_ID,
        artistId,
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      return songs
          .where((s) => s.duration != null && s.duration! > 0)
          .map((s) => SongModel(
                id: s.id,
                title: s.title,
                artist: s.artist ?? '<unknown>',
                album: s.album ?? 'Unknown Album',
                duration: s.duration ?? 0,
                path: s.data,
                uri: s.uri,
                dateAdded: s.dateAdded ?? 0,
                size: s.size,
                albumId: s.albumId,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static QueryArtworkWidget getArtwork(int id,
      {ArtworkType type = ArtworkType.AUDIO, double size = 50}) {
    return QueryArtworkWidget(
      id: id,
      type: type,
      artworkHeight: size,
      artworkWidth: size,
      artworkFit: BoxFit.cover,
      artworkBorder: BorderRadius.circular(8),
      nullArtworkWidget: defaultArtwork(size),
      keepOldArtwork: true,
    );
  }

  static Widget defaultArtwork(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E63), Color(0xFF3F51B5)],
        ),
      ),
      child: Icon(Icons.music_note_rounded,
          color: Colors.white70, size: size * 0.5),
    );
  }
}
