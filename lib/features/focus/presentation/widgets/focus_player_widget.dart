import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/focus_track.dart';
import '../../services/focus_music_service.dart';
import '../pages/focus_playlist_page.dart';

class FocusPlayerWidget extends StatelessWidget {
  final bool showPlaylistOnTap;

  const FocusPlayerWidget({super.key, this.showPlaylistOnTap = true});

  @override
  Widget build(BuildContext context) {
    final musicService = FocusMusicService();

    return StreamBuilder<FocusTrack?>(
      stream: musicService.currentTrackStream,
      initialData: musicService.currentTrack,
      builder: (context, trackSnapshot) {
        final currentTrack = trackSnapshot.data;

        if (currentTrack == null) {
          return _buildEmptyState(context);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF12211A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Info + Controls
              GestureDetector(
                onTap:
                    showPlaylistOnTap
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FocusPlaylistPage(),
                            ),
                          );
                        }
                        : null,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E054).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Color(0xFF00E054),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentTrack.category,
                            style: const TextStyle(
                              color: AppColors.textSubtle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: musicService.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final isPlaying = playerState?.playing ?? false;

                        return ValueListenableBuilder<bool>(
                          valueListenable: musicService.adaptiveLoading,
                          builder: (context, isLoading, child) {
                            if (isLoading ||
                                processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
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
                              onTap: () => musicService.togglePlayPause(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00E054),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Progress Bar
              StreamBuilder<Duration>(
                stream: musicService.player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration =
                      musicService.player.duration ??
                      currentTrack.duration ??
                      Duration.zero;

                  return ProgressBar(
                    progress: position,
                    buffered: musicService.player.bufferedPosition,
                    total: duration,
                    onSeek: (duration) {
                      musicService.player.seek(duration);
                    },
                    barHeight: 4,
                    baseBarColor: Colors.white.withValues(alpha: 0.1),
                    bufferedBarColor: Colors.white.withValues(alpha: 0.1),
                    progressBarColor: const Color(0xFF00E054),
                    thumbColor: const Color(0xFF00E054),
                    thumbRadius: 6,
                    timeLabelTextStyle: const TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 10,
                      fontFamily: 'Inter', // Assuming default font
                    ),
                    timeLabelPadding: 4,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap:
          showPlaylistOnTap
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FocusPlaylistPage(),
                  ),
                );
              }
              : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF12211A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.music_note, color: AppColors.textSubtle),
            ),
            const SizedBox(width: 12),
            const Text(
              "Select Focus Music",
              style: TextStyle(
                color: AppColors.textSubtle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
