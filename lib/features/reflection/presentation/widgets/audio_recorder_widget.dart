import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/audio_recorder_service.dart';
import '../../../../core/services/speech_to_text_service.dart';
import '../../../../core/theme/app_colors.dart';

enum RecordingState { idle, recording, processing, complete, error }

class AudioRecorderWidget extends StatefulWidget {
  final Function(String audioUrl, String transcript) onRecordingComplete;
  final VoidCallback? onCancel;

  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onCancel,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final SpeechToTextService _speechService = SpeechToTextService();

  RecordingState _state = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  String _transcript = '';
  String? _errorMessage;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
  }

  Future<void> _initializeSpeechRecognition() async {
    await _speechService.initialize();
  }

  Future<void> _startRecording() async {
    setState(() {
      _state = RecordingState.recording;
      _transcript = '';
      _errorMessage = null;
    });

    // Start audio recording
    // Start audio recording
    try {
      await _recorderService.startRecording();
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = RecordingState.error;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
      return;
    }

    // Listen to recording duration
    _durationSubscription = _recorderService.recordingDuration.listen((
      duration,
    ) {
      setState(() {
        _recordingDuration = duration;
      });
    });

    // Start speech-to-text
    final speechAvailable = await _speechService.startListening(
      onResult: (text) {
        setState(() {
          _transcript = text;
        });
      },
      onPartialResult: (text) {
        setState(() {
          _transcript = text;
        });
      },
    );

    if (!speechAvailable) {
      if (mounted) {
        setState(() {
          _transcript = "Speech Unavailable: ${_speechService.lastError}";
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _state = RecordingState.processing;
    });

    // Stop speech recognition
    await _speechService.stopListening();

    // Stop recording and get file path
    final filePath = await _recorderService.stopRecording();
    _durationSubscription?.cancel();

    if (filePath == null) {
      setState(() {
        _state = RecordingState.error;
        _errorMessage = 'Failed to save recording';
      });
      return;
    }

    // Success
    setState(() {
      _state = RecordingState.complete;
    });

    // Callback with results (filePath instead of URL)
    widget.onRecordingComplete(filePath, _transcript);
  }

  Future<void> _cancelRecording() async {
    await _recorderService.cancelRecording();
    await _speechService.cancelListening();
    _durationSubscription?.cancel();

    setState(() {
      _state = RecordingState.idle;
      _transcript = '';
      _recordingDuration = Duration.zero;
      _errorMessage = null;
    });

    widget.onCancel?.call();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _recorderService.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121413), // card-dark
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Voice-to-Sync",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Capture your stream of consciousness.",
                    style: TextStyle(
                      color: Color(0xFF94A3B8), // slate-400
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF080A09), // surface-dark
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _state == RecordingState.recording
                                ? Colors.red
                                : const Color(0xFF00E054),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                _state == RecordingState.recording
                                    ? Colors.red
                                    : const Color(0xFF00E054),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _state == RecordingState.recording ? "REC" : "READY",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFFCBD5E1), // slate-300
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Waveform and Record Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Bars
              _buildBar(12),
              const SizedBox(width: 4),
              _buildBar(20),
              const SizedBox(width: 4),
              _buildBar(8),
              const SizedBox(width: 4),
              _buildBar(16),
              const SizedBox(width: 24),

              // Mic Button
              _buildRecordButton(),

              const SizedBox(width: 24),
              // Right Bars
              _buildBar(16),
              const SizedBox(width: 4),
              _buildBar(8),
              const SizedBox(width: 4),
              _buildBar(24),
              const SizedBox(width: 4),
              _buildBar(12),
            ],
          ),
          const SizedBox(height: 24),

          // Status Text or Timer
          if (_state == RecordingState.recording)
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                color: Color(0xFF00E054),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            )
          else
            const Text(
              "CLICK TO RECORD",
              style: TextStyle(
                color: Color(0xFF94A3B8), // slate-400
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),

          // Transcript Preview (Always show when recording or has text)
          if (_state == RecordingState.recording || _transcript.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.transcribe,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'LIVE TRANSCRIPT',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_state == RecordingState.recording &&
                          _transcript.isEmpty) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _transcript.isEmpty ? "Listening..." : _transcript,
                    style: TextStyle(
                      color:
                          _transcript.isEmpty
                              ? const Color(0xFF475569)
                              : Colors.white,
                      fontSize: 14,
                      height: 1.5,
                      fontStyle:
                          _transcript.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],

          // Error Message
          if (_state == RecordingState.error && _errorMessage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          if (_state == RecordingState.recording) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelRecording,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stopRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E054),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],

          // Processing Indicator
          if (_state == RecordingState.processing) ...[
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E054)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Uploading...',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    final isRecording = _state == RecordingState.recording;
    final isProcessing = _state == RecordingState.processing;

    return GestureDetector(
      onTap:
          isProcessing
              ? null
              : (isRecording ? _stopRecording : _startRecording),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 15,
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Colors.black,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildBar(double height) {
    final isRecording = _state == RecordingState.recording;

    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color:
            isRecording
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
