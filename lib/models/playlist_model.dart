import 'dart:convert';

class PlaylistModel {
  final String id;
  String name;
  List<int> songIds;
  final DateTime createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  int get songCount => songIds.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PlaylistModel.fromJson(Map<String, dynamic> json) => PlaylistModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        songIds: (json['songIds'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  static String encodeList(List<PlaylistModel> playlists) =>
      jsonEncode(playlists.map((p) => p.toJson()).toList());

  static List<PlaylistModel> decodeList(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => PlaylistModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PlaylistModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
