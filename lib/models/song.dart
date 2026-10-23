class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String artwork;
  final String? previewUrl;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artwork,
    this.previewUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['trackId'] as int? ?? 0,
      title: json['trackName'] as String? ?? 'Unknown Song',
      artist: json['artistName'] as String? ?? 'Unknown Artist',
      album: json['collectionName'] as String? ?? 'Unknown Album',
      artwork: (json['artworkUrl100'] as String? ?? '')
          .replaceAll('100x100bb', '300x300bb'),
      previewUrl: json['previewUrl'] as String?,
    );
  }
}

