import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/theme_service.dart';
import '../../data/models/playlist_model.dart';
import '../../data/repositories/playlist_repository.dart';
import 'playlist_details_page.dart';

class UserPlaylistsPage extends StatefulWidget {
  const UserPlaylistsPage({super.key});

  @override
  State<UserPlaylistsPage> createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends State<UserPlaylistsPage> {
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

  Future<void> _createPlaylist() async {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final colors = themeService.colors;
        return Scaffold(
          backgroundColor: const Color(0xFF0B1410),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "My Playlists",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: colors.primary),
                onPressed: _createPlaylist,
              ),
            ],
          ),
          body:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  )
                  : _playlists.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.queue_music,
                          size: 64,
                          color: colors.textSubtle,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No playlists yet",
                          style: TextStyle(
                            color: colors.textSubtle,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _createPlaylist,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                          ),
                          child: const Text(
                            "Create One",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = _playlists[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.music_note,
                              color: colors.primary,
                            ),
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "Created on ${_formatDate(playlist.createdAt)}",
                            style: TextStyle(
                              color: colors.textSubtle,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: colors.textSubtle,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PlaylistDetailsPage(playlist: playlist),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
