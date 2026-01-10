import 'package:flutter/material.dart';

import '../../../../core/models/data_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';

class ReflectionDetailPage extends StatefulWidget {
  final Reflection reflection;

  const ReflectionDetailPage({super.key, required this.reflection});

  @override
  State<ReflectionDetailPage> createState() => _ReflectionDetailPageState();
}

class _ReflectionDetailPageState extends State<ReflectionDetailPage> {
  final _audioPlayerService = AudioPlayerService();
  bool _isLoadingAudio = false;
  bool _isAudioLoaded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final audioUrl = widget.reflection.audioUrl;
    if (audioUrl != null && audioUrl.isNotEmpty) {
      setState(() => _isLoadingAudio = true);
      try {
        await _audioPlayerService.loadAudio(audioUrl);
        if (mounted) {
          setState(() {
            _isLoadingAudio = false;
            _isAudioLoaded = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingAudio = false;
            _errorMessage = 'Failed to load audio';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _audioPlayerService.dispose();
    super.dispose();
  }

  String _getMoodEmoji(int? moodScore) {
    if (moodScore == null) return '😐';
    if (moodScore >= 9) return '🤩';
    if (moodScore >= 7) return '😊';
    if (moodScore >= 5) return '😐';
    if (moodScore >= 3) return '😕';
    return '😢';
  }

  String _getMoodText(int? moodScore) {
    if (moodScore == null) return 'Neutral';
    if (moodScore >= 9) return 'Ecstatic';
    if (moodScore >= 7) return 'Happy Optimistic';
    if (moodScore >= 5) return 'Neutral';
    if (moodScore >= 3) return 'Slightly Down';
    return 'Low Energy';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1410),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Summary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completed Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E054).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00E054),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: Color(0xFF00E054),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              widget.reflection.title ?? 'Morning Clarity Sync',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(widget.reflection.date),
              style: const TextStyle(color: AppColors.textSubtle, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Audio Player (if audio exists)
            if (widget.reflection.audioUrl != null) _buildAudioPlayer(),

            if (widget.reflection.audioUrl != null) const SizedBox(height: 24),

            // Mood Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF12211A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MOOD',
                          style: TextStyle(
                            color: AppColors.textSubtle,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMoodText(widget.reflection.moodScore),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E054).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getMoodEmoji(widget.reflection.moodScore),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Productivity Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF12211A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PRODUCTIVITY',
                        style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${widget.reflection.productivityScore ?? 0}%',
                        style: const TextStyle(
                          color: Color(0xFF00E054),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor:
                          (widget.reflection.productivityScore ?? 0) / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E054),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Key Takeaways Section
            const Text(
              'KEY TAKEAWAYS',
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            if (widget.reflection.takeaways == null ||
                widget.reflection.takeaways!.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No key takeaways',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...widget.reflection.takeaways!.map(
                (takeaway) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF00E054),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          takeaway,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Reflection Notes Section (Highlight, Blocker, Improvement)
            const Text(
              'REFLECTION NOTES',
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildReflectionNotes(),
            const SizedBox(height: 32),

            // Full Transcript Section (Audio transcript)
            const Text(
              'FULL TRANSCRIPT',
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildAudioTranscript(),
            const SizedBox(height: 32),

            // Convert to Action Plan Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E054),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Convert to Action Plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingAudio) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00E054)),
      );
    }

    return StreamBuilder<Duration>(
      stream: _audioPlayerService.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _audioPlayerService.duration ?? Duration.zero;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF12211A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'ORIGINAL AUDIO',
                    style: TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Color(0xFF00E054),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF00E054),
                  inactiveTrackColor: const Color(
                    0xFF00E054,
                  ).withValues(alpha: 0.2),
                  thumbColor: const Color(0xFF00E054),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                ),
                child: Slider(
                  value: position.inSeconds.toDouble().clamp(
                    0,
                    duration.inSeconds.toDouble(),
                  ),
                  min: 0,
                  max:
                      duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1,
                  onChanged: (value) {
                    _audioPlayerService.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),

              const SizedBox(height: 8),
              // Timestamps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Controls
              StreamBuilder<PlayerState>(
                stream: _audioPlayerService.playerStateStream,
                builder: (context, stateSnapshot) {
                  final playerState = stateSnapshot.data;
                  final isPlaying = playerState?.playing ?? false;
                  final processing =
                      playerState?.processingState == ProcessingState.buffering;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed:
                            () => _audioPlayerService.seekBackward(
                              const Duration(seconds: 10),
                            ),
                      ),
                      const SizedBox(width: 16),
                      if (processing)
                        const SizedBox(
                          width: 56,
                          height: 56,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Color(0xFF00E054),
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap:
                              isPlaying
                                  ? _audioPlayerService.pause
                                  : _audioPlayerService.play,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E054),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed:
                            () => _audioPlayerService.seekForward(
                              const Duration(seconds: 10),
                            ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReflectionNotes() {
    final highlight = widget.reflection.highlight ?? '';
    final blocker = widget.reflection.blocker ?? '';
    final improvement = widget.reflection.improvement ?? '';

    // Check if all fields are empty
    if (highlight.isEmpty && blocker.isEmpty && improvement.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF12211A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Text(
          'No notes recorded.',
          style: TextStyle(color: AppColors.textSubtle, fontSize: 14),
        ),
      );
    }

    return Column(
      children: [
        if (highlight.isNotEmpty) ...[
          _buildTranscriptCard(
            'Highlight',
            highlight,
            Icons.emoji_events,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),
        ],
        if (blocker.isNotEmpty) ...[
          _buildTranscriptCard(
            'Blocker',
            blocker,
            Icons.block,
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
        ],
        if (improvement.isNotEmpty)
          _buildTranscriptCard(
            'Improvement',
            improvement,
            Icons.trending_up,
            const Color(0xFF3B82F6),
          ),
      ],
    );
  }

  Widget _buildAudioTranscript() {
    final transcript = widget.reflection.blockerNote ?? '';

    if (transcript.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF12211A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: AppColors.textSubtle,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No transcript recorded.',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and copy button
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'FULL TRANSCRIPT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Copy to clipboard functionality
                },
                child: const Text(
                  'Copy',
                  style: TextStyle(
                    color: Color(0xFF00E054),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Transcript with timestamps (simplified - you can enhance this later)
          _buildTranscriptLine(
            '00:00',
            transcript.substring(
              0,
              transcript.length > 100 ? 100 : transcript.length,
            ),
          ),
          if (transcript.length > 100) ...[
            const SizedBox(height: 12),
            _buildTranscriptLine(
              '00:15',
              transcript.substring(
                100,
                transcript.length > 200 ? 200 : transcript.length,
              ),
            ),
          ],
          if (transcript.length > 200) ...[
            const SizedBox(height: 12),
            _buildTranscriptLine('00:32', transcript.substring(200)),
          ],
          const SizedBox(height: 16),
          // Read Full Transcript button
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 16,
              ),
              label: const Text(
                'Read Full Transcript',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptLine(String timestamp, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timestamp,
          style: const TextStyle(
            color: AppColors.textSubtle,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Use createdAt if available, otherwise use date
    final displayDate = widget.reflection.createdAt ?? date;

    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final hour =
        displayDate.hour > 12
            ? displayDate.hour - 12
            : (displayDate.hour == 0 ? 12 : displayDate.hour);
    final period = displayDate.hour >= 12 ? 'PM' : 'AM';

    return '${days[displayDate.weekday - 1]}, ${months[displayDate.month - 1]} ${displayDate.day} • $hour:${displayDate.minute.toString().padLeft(2, '0')} $period';
  }
}
