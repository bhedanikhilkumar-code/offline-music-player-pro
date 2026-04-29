class AlbumModel {
  final int id;
  final String name;
  final String artist;
  final int songCount;
  final int? firstYear;

  AlbumModel({
    required this.id,
    required this.name,
    required this.artist,
    required this.songCount,
    this.firstYear,
  });

  String get displayName => name.isEmpty ? 'Unknown Album' : name;
  String get displayArtist => (artist.isEmpty || artist == '<unknown>') ? '<unknown>' : artist;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AlbumModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
