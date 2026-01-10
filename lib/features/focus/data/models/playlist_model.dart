class Playlist {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PlaylistItem {
  final String id;
  final String playlistId;
  final String videoId;
  final String title;
  final String author;
  final String? imageUrl;
  final DateTime addedAt;
  final int sortOrder;

  PlaylistItem({
    required this.id,
    required this.playlistId,
    required this.videoId,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.addedAt,
    this.sortOrder = 0,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'],
      playlistId: json['playlist_id'],
      videoId: json['video_id'],
      title: json['title'],
      author: json['author'],
      imageUrl: json['image_url'],
      addedAt: DateTime.parse(json['added_at']),
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
