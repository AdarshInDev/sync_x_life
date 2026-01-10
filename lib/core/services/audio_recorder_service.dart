import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  FlutterSoundRecorder? _recorder;
  bool _isRecorderInitialized = false;
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;
  final _durationController = StreamController<Duration>.broadcast();

  Stream<Duration> get recordingDuration => _durationController.stream;
  bool get isRecording => _recorder?.isRecording ?? false;

  /// Check and request microphone permission
  Future<bool> checkPermissions() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }

  /// Initialize recorder
  Future<void> _initRecorder() async {
    if (_isRecorderInitialized) return;

    _recorder = FlutterSoundRecorder();

    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: true,
      ),
    );

    await _recorder!.openRecorder();
    _isRecorderInitialized = true;
  }

  /// Start recording audio
  /// Throws exception if recording fails to start
  Future<void> startRecording() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        throw Exception(
          'Microphone permission denied. Please enable it in settings.',
        );
      }

      await _initRecorder();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/reflection_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder!.startRecorder(toFile: filePath, codec: Codec.aacMP4);

      _recordingDuration = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        _durationController.add(_recordingDuration);
      });
    } catch (e) {
      print('Error starting recording: $e');
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    try {
      if (!isRecording) return null;

      _timer?.cancel();
      final path = await _recorder!.stopRecorder();
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      await _recorder!.pauseRecorder();
      _timer?.cancel();
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      await _recorder!.resumeRecorder();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration += const Duration(seconds: 1);
        _durationController.add(_recordingDuration);
      });
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      _timer?.cancel();
      await _recorder!.stopRecorder();
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _recorder?.closeRecorder();
    _recorder = null;
    _durationController.close();
  }
}
