import '../models/song_model.dart';

class SortUtils {
  static List<SongModel> sortSongs(List<SongModel> songs, String sortType) {
    final sorted = List<SongModel>.from(songs);
    switch (sortType) {
      case 'title':
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'artist':
        sorted.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case 'album':
        sorted.sort((a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()));
        break;
      case 'duration':
        sorted.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'date':
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'size':
        sorted.sort((a, b) => b.size.compareTo(a.size));
        break;
    }
    return sorted;
  }
}
