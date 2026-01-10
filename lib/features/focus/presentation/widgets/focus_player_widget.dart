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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF12211A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Track Info Row
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E054).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: Color(0xFF00E054),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentTrack.category,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Progress Bar with Timestamps
                StreamBuilder<Duration>(
                  stream: musicService.player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration =
                        musicService.player.duration ?? Duration.zero;

                    return Column(
                      children: [
                        ProgressBar(
                          progress: position,
                          total: duration,
                          onSeek: (value) => musicService.player.seek(value),
                          barHeight: 5,
                          thumbRadius: 8,
                          timeLabelLocation: TimeLabelLocation.none,
                          progressBarColor: const Color(0xFF00E054),
                          baseBarColor: Colors.white.withValues(alpha: 0.12),
                          bufferedBarColor: Colors.white.withValues(alpha: 0.2),
                          thumbColor: const Color(0xFF00E054),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                // Control Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loop Button
                    StreamBuilder<LoopMode>(
                      stream: musicService.loopModeStream,
                      builder: (context, snapshot) {
                        final loopMode = snapshot.data ?? LoopMode.off;
                        const icons = {
                          LoopMode.off: Icons.repeat_rounded,
                          LoopMode.one: Icons.repeat_one_rounded,
                          LoopMode.all: Icons.repeat_rounded,
                        };
                        final color =
                            loopMode == LoopMode.off
                                ? Colors.white.withValues(alpha: 0.4)
                                : const Color(0xFF00E054);
                        return IconButton(
                          icon: Icon(icons[loopMode], color: color, size: 26),
                          onPressed: musicService.cycleLoopMode,
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Previous Button
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: musicService.skipToPrevious,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 16),
                    // Play/Pause Button
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
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  color: Color(0xFF00E054),
                                ),
                              );
                            }

                            return GestureDetector(
                              onTap: () => musicService.togglePlayPause(),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E054),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00E054,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // Next Button
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: musicService.skipToNext,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    // Shuffle Button
                    ValueListenableBuilder<bool>(
                      valueListenable: musicService.isShuffleMode,
                      builder: (context, isShuffle, child) {
                        return IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color:
                                isShuffle
                                    ? const Color(0xFF00E054)
                                    : Colors.white.withValues(alpha: 0.4),
                            size: 26,
                          ),
                          onPressed: musicService.toggleShuffle,
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00E054).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, color: Color(0xFF00E054)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "No track playing",
              style: TextStyle(color: AppColors.textSubtle, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
