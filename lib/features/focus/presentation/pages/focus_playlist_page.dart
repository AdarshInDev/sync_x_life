import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:provider/provider.dart';

import '../../../../core/services/theme_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/focus_track.dart';
import '../../services/focus_music_service.dart';
import '../widgets/focus_player_widget.dart';

class FocusPlaylistPage extends StatefulWidget {
  const FocusPlaylistPage({super.key});

  @override
  State<FocusPlaylistPage> createState() => _FocusPlaylistPageState();
}

class _FocusPlaylistPageState extends State<FocusPlaylistPage> {
  final _musicService = FocusMusicService();

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
              "Focus Beats",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<FocusTrack?>(
                  stream: _musicService.currentTrackStream,
                  initialData: _musicService.currentTrack,
                  builder: (context, trackSnapshot) {
                    final currentTrack = trackSnapshot.data;

                    return StreamBuilder<PlayerState>(
                      stream: _musicService.player.playerStateStream,
                      builder: (context, playerSnapshot) {
                        final isPlaying = playerSnapshot.data?.playing ?? false;
                        final processingState =
                            playerSnapshot.data?.processingState ??
                            ProcessingState.idle;

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: kFocusTracks.length,
                          itemBuilder: (context, index) {
                            final track = kFocusTracks[index];
                            final isSelected = currentTrack?.id == track.id;
                            final isTrackPlaying = isSelected && isPlaying;
                            final isLoading =
                                isSelected &&
                                (processingState == ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering);

                            return Container(
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
                                          : Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF00E054,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    color: const Color(0xFF00E054),
                                  ),
                                ),
                                title: Text(
                                  track.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  track.category,
                                  style: TextStyle(
                                    color: colors.textSubtle,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: _buildPlayButton(
                                  isPlaying: isTrackPlaying,
                                  isLoading: isLoading,
                                  onTap: () {
                                    if (isSelected) {
                                      _musicService.togglePlayPause();
                                    } else {
                                      _musicService.playTrack(track);
                                    }
                                  },
                                ),
                                onTap: () {
                                  if (isSelected) {
                                    _musicService.togglePlayPause();
                                  } else {
                                    _musicService.playTrack(track);
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Sticky Player
              const BottomPlayerWrapper(),
            ],
          ),
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
    return Container(
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
    );
  }

  IconData _getIcon(String category) {
    switch (category) {
      case 'Binaural':
        return Icons.headphones;
      case 'Meditation':
        return Icons.self_improvement;
      default:
        return Icons.music_note;
    }
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
