import '../../../../core/services/supabase_service.dart';
import '../models/playlist_model.dart';

class PlaylistRepository {
  final _supabase = SupabaseService();

  Future<void> createPlaylist(String name) async {
    await _supabase.createPlaylist(name);
  }

  Future<List<Playlist>> getUserPlaylists() async {
    return await _supabase.getPlaylists();
  }

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String videoId,
    required String title,
    required String author,
    String? imageUrl,
  }) async {
    await _supabase.addToPlaylist(
      playlistId: playlistId,
      videoId: videoId,
      title: title,
      author: author,
      imageUrl: imageUrl,
    );
  }

  Future<List<PlaylistItem>> getSongsInPlaylist(String playlistId) async {
    return await _supabase.getPlaylistItems(playlistId);
  }

  Future<void> updatePlaylistOrder(List<PlaylistItem> items) async {
    await _supabase.updatePlaylistItemsOrder(items);
  }
}
