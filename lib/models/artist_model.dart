class ArtistModel {
  final int id;
  final String name;
  final int songCount;
  final int albumCount;

  ArtistModel({
    required this.id,
    required this.name,
    required this.songCount,
    required this.albumCount,
  });

  String get displayName => (name.isEmpty || name == '<unknown>') ? '<unknown>' : name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ArtistModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
