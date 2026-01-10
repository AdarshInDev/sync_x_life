import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/focus_track.dart';
import '../../data/models/playlist_model.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../services/focus_music_service.dart';
import '../widgets/focus_player_widget.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  final _repository = PlaylistRepository();
  final _musicService = FocusMusicService.instance;
  List<PlaylistItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getSongsInPlaylist(widget.playlist.id);
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  void _playPlaylist(int initialIndex) {
    if (_items.isEmpty) return;

    final tracks =
        _items.map((item) {
          return FocusTrack(
            id: item.videoId,
            title: item.title,
            category: item.author, // Using author as category/subtitle
            imageUrl: item.imageUrl ?? '',
            url: '', // Will be resolved lazily
          );
        }).toList();

    _musicService.playPlaylist(tracks, initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1410),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.playlist.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : _items.isEmpty
                    ? const Center(
                      child: Text(
                        "No songs in this playlist.",
                        style: TextStyle(color: AppColors.textSubtle),
                      ),
                    )
                    : _buildSongList(),
          ),
          const BottomPlayerWrapper(),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return StreamBuilder<FocusTrack?>(
      stream: _musicService.currentTrackStream,
      initialData: _musicService.currentTrack,
      builder: (context, trackSnapshot) {
        final currentTrack = trackSnapshot.data;

        return StreamBuilder<PlayerState>(
          stream: _musicService.player.playerStateStream,
          builder: (context, playerSnapshot) {
            final isPlaying = playerSnapshot.data?.playing ?? false;
            final processingState =
                playerSnapshot.data?.processingState ?? ProcessingState.idle;

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
                _repository.updatePlaylistOrder(_items);
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                final isSelected = currentTrack?.id == item.videoId;
                final isTrackPlaying = isSelected && isPlaying;
                final isLoading =
                    isSelected &&
                    (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering);

                return Container(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF1F352A)
                            : const Color(0xFF12211A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF00E054)
                              : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.white24),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              item.imageUrl != null
                                  ? Image.network(
                                    item.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.surfaceHighlight,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: AppColors.primary,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      item.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 12,
                      ),
                    ),
                    trailing: _buildPlayButton(
                      isPlaying: isTrackPlaying,
                      isLoading: isLoading,
                      onTap: () {
                        if (isSelected) {
                          _musicService.togglePlayPause();
                        } else {
                          _playPlaylist(index);
                        }
                      },
                    ),
                    onTap: () {
                      if (isSelected) {
                        _musicService.togglePlayPause();
                      } else {
                        _playPlaylist(index);
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlayButton({
    required bool isPlaying,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF00E054),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF00E054),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
          size: 20,
        ),
      ),
    );
  }
}

class BottomPlayerWrapper extends StatelessWidget {
  const BottomPlayerWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1410),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: const FocusPlayerWidget(showPlaylistOnTap: false),
      ),
    );
  }
}
