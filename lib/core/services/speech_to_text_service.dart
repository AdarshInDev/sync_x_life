import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  String _recognizedText = '';
  String _lastError = '';

  bool get isInitialized => _isInitialized;
  String get recognizedText => _recognizedText;
  String get lastError => _lastError;
  bool get isListening => _speech.isListening;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    _lastError = '';
    try {
      // Check microphone permission
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          _lastError = 'Microphone permission denied';
          return false;
        }
      }

      // Check speech recognition permission (iOS)
      final speechStatus = await Permission.speech.status;
      if (!speechStatus.isGranted) {
        final result = await Permission.speech.request();
        if (!result.isGranted) {
          _lastError = 'Speech recognition permission denied';
          return false;
        }
      }

      // Initialize speech recognition
      _isInitialized = await _speech.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          _lastError = error.errorMsg;
        },
        onStatus: (status) => print('Speech recognition status: $status'),
      );

      if (!_isInitialized && _lastError.isEmpty) {
        _lastError = 'Speech initialization failed (unknown reason)';
      }

      return _isInitialized;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      _lastError = 'Exception: $e';
      return false;
    }
  }

  /// Start listening and transcribing
  Future<bool> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    _recognizedText = '';

    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;

        if (result.finalResult) {
          onResult(_recognizedText);
        } else if (onPartialResult != null) {
          onPartialResult(_recognizedText);
        }
      },
      listenFor: const Duration(minutes: 5), // Max recording time
      pauseFor: const Duration(seconds: 3), // Pause detection
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );

    return true;
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
    _recognizedText = '';
  }

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }

  /// Get list of available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speech.locales();
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
  }
}
