import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../data/models/focus_track.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => FocusMusicService._internal(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.adarsh.focus.channel.audio',
      androidNotificationChannelName: 'Focus Music',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class FocusMusicService extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  static FocusMusicService? _instance;
  static FocusMusicService get instance => _instance!;

  factory FocusMusicService() {
    return _instance!;
  }

  final AudioPlayer _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();
  FocusTrack? _currentFocusTrack;

  final _trackController = StreamController<FocusTrack?>.broadcast();
  Stream<FocusTrack?> get currentTrackStream => _trackController.stream;
  FocusTrack? get currentTrack => _currentFocusTrack;

  // Expose player for UI widgets (FocusPlayerWidget)
  AudioPlayer get player => _player;

  FocusMusicService._internal() {
    _instance = this;
    _init();
  }

  void _init() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState:
              const {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });

    _player.durationStream.listen((duration) {
      if (duration != null && mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });

    _loadLastTrack();
  }

  // Legacy init method - no op as valid init happens in constructor/AudioService logic
  Future<void> init() async {}

  Future<void> _loadLastTrack() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_focus_track_id');
      final lastTitle = prefs.getString('last_track_title');

      if (lastId != null) {
        // Create a track object (url might be stale but good for UI)
        final track = FocusTrack(
          id: lastId,
          title: lastTitle ?? 'Last Played',
          category: 'Focus', // Generic fallback
          url: '', // Stale
          imageUrl:
              'assets/images/lofi_cover.png', // Generic fallback or need to save this too
        );

        _currentFocusTrack = track;
        _trackController.add(track);

        // Also update MediaItem so notification shows something (paused)
        final item = MediaItem(
          id: track.id,
          title: track.title,
          artist: track.category,
          duration: Duration.zero,
          artUri: Uri.parse(''), // Placeholder
        );
        mediaItem.add(item);
      }
    } catch (e) {
      print("Error loading last track: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> playTrack(FocusTrack track) async {
    _currentFocusTrack = track;
    _trackController.add(track);

    final item = MediaItem(
      id: track.id,
      title: track.title,
      artist: track.category,
      artUri: Uri.parse(
        track.imageUrl.startsWith('http') ? track.imageUrl : '',
      ),
      duration: track.duration,
    );
    mediaItem.add(item);

    try {
      await _player.setUrl(track.url);
      _player.play(); // Don't await completion
      _saveLastTrack(track);
    } catch (e) {
      print("Error playing track: $e");
    }
  }

  // Custom loading state for the specific "bypass" fetch phase
  final ValueNotifier<bool> adaptiveLoading = ValueNotifier(false);
  String? _loadingVideoId;

  Future<void> playYoutubeTrack(
    String videoId,
    String title,
    String author,
    String imageUrl,
  ) async {
    // 1. Prevent re-loading the same track if already loading
    if (adaptiveLoading.value && _loadingVideoId == videoId) {
      return;
    }

    try {
      // 2. Set new loading target (overrides any previous ongoing load)
      _loadingVideoId = videoId;
      adaptiveLoading.value = true;

      if (_player.playing) {
        await _player.stop();
      }

      final video = await _yt.videos.get(videoId);

      // Check if this load was superseded by a newer one
      if (_loadingVideoId != videoId) return;

      final duration = video.duration;

      final manifest = await _yt.videos.streamsClient.getManifest(
        videoId,
        ytClients: [YoutubeApiClient.ios, YoutubeApiClient.androidVr],
      );

      if (_loadingVideoId != videoId) return;

      final audioStreamInfo = manifest.audioOnly.first;

      final track = FocusTrack(
        id: videoId,
        title: title,
        category: author,
        url: audioStreamInfo.url.toString(),
        imageUrl: imageUrl,
        duration: duration,
      );

      await _player.setVolume(1.0);

      if (_loadingVideoId != videoId) return;

      await playTrack(track);
    } catch (e) {
      print("Error playing YouTube track: $e");
    } finally {
      // Only clear loading state if WE are still the active loader
      if (_loadingVideoId == videoId) {
        adaptiveLoading.value = false;
        _loadingVideoId = null;
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _saveLastTrack(FocusTrack track) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_focus_track_id', track.id);
      if (track.category != 'Binaural' && track.category != 'Meditation') {
        await prefs.setString('last_track_title', track.title);
      }
    } catch (e) {
      print("Error saving last track: $e");
    }
  }
}
