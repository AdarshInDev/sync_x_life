import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/theme_service.dart';
import '../../data/models/playlist_model.dart';
import '../../data/repositories/playlist_repository.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final String videoId;
  final String title;
  final String author;
  final String imageUrl;

  const AddToPlaylistSheet({
    super.key,
    required this.videoId,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  final _repository = PlaylistRepository();
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _repository.getUserPlaylists();
    if (mounted) {
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    }
  }

  Future<void> _createPlaylist(BuildContext context) async {
    final colors = Provider.of<ThemeService>(context, listen: false).colors;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: colors.surface,
            title: const Text(
              'New Playlist',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Playlist Name',
                hintStyle: TextStyle(color: colors.textSubtle),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colors.primary),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );

    if (name != null && name.isNotEmpty) {
      await _repository.createPlaylist(name);
      _loadPlaylists();
    }
  }

  Future<void> _addToPlaylist(Playlist playlist) async {
    final colors = Provider.of<ThemeService>(context, listen: false).colors;
    try {
      await _repository.addSongToPlaylist(
        playlistId: playlist.id,
        videoId: widget.videoId,
        title: widget.title,
        author: widget.author,
        imageUrl: widget.imageUrl,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to ${playlist.name}'),
            backgroundColor: colors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final colors = themeService.colors;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add to Playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: colors.primary),
                    onPressed: () => _createPlaylist(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: colors.primary))
              else if (_playlists.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "No playlists yet.",
                        style: TextStyle(color: colors.textSubtle),
                      ),
                      TextButton(
                        onPressed: () => _createPlaylist(context),
                        child: Text(
                          "Create New Playlist",
                          style: TextStyle(color: colors.primary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.queue_music, color: colors.primary),
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.add, color: colors.textSubtle),
                      onTap: () => _addToPlaylist(playlist),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
