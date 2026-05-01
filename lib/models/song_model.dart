class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration; // in milliseconds
  final String path;
  final String? uri;
  final int dateAdded;
  final int size;
  final String? albumArtPath;
  final int? albumId;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.path,
    this.uri,
    required this.dateAdded,
    required this.size,
    this.albumArtPath,
    this.albumId,
  });

  String get durationFormatted {
    final d = Duration(milliseconds: duration);
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String get displayTitle {
    if (title.isEmpty || title == '<unknown>') {
      // Extract filename without extension
      final fileName = path.isEmpty ? '' : path.split('/').last;
      if (fileName.isEmpty) return 'Unknown';
      final dotIndex = fileName.lastIndexOf('.');
      return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
    }
    return title;
  }

  String get displayArtist {
    return (artist.isEmpty || artist == '<unknown>') ? '<unknown>' : artist;
  }

  String get folderPath {
    final lastSlash = path.lastIndexOf('/');
    return lastSlash > 0 ? path.substring(0, lastSlash) : '/';
  }

  String get folderName {
    final folder = folderPath;
    final lastSlash = folder.lastIndexOf('/');
    return lastSlash >= 0 ? folder.substring(lastSlash + 1) : folder;
  }

  String get bitrateFormatted {
    if (duration > 0 && size > 0) {
      final bitrate = (size * 8) / (duration / 1000) / 1000;
      return '${bitrate.round()}kbps';
    }
    return 'Unknown';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'duration': duration,
        'path': path,
        'uri': uri,
        'dateAdded': dateAdded,
        'size': size,
        'albumArtPath': albumArtPath,
        'albumId': albumId,
      };

  factory SongModel.fromJson(Map<String, dynamic> json) => SongModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        artist: json['artist'] ?? '<unknown>',
        album: json['album'] ?? 'Unknown Album',
        duration: json['duration'] ?? 0,
        path: json['path'] ?? '',
        uri: json['uri'],
        dateAdded: json['dateAdded'] ?? 0,
        size: json['size'] ?? 0,
        albumArtPath: json['albumArtPath'],
        albumId: json['albumId'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SongModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
