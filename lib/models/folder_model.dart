import 'song_model.dart';

class FolderModel {
  final String path;
  final String name;
  final List<SongModel> songs;

  FolderModel({
    required this.path,
    required this.name,
    required this.songs,
  });

  int get songCount => songs.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FolderModel && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
