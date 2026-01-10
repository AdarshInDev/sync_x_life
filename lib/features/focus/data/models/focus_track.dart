class FocusTrack {
  final String id;
  final String title;
  final String category; // e.g., 'Binaural', 'Lo-Fi', 'Nature'
  final String url;
  final String imageUrl; // For the UI

  final Duration? duration;

  const FocusTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.imageUrl,
    this.duration,
  });
}

// Predefined tracks
final List<FocusTrack> kFocusTracks = [
  FocusTrack(
    id: '1',
    title: 'Deep Focus (Alpha 10Hz)',
    category: 'Binaural',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    imageUrl: 'assets/images/focus_binaural.png', // Placeholder or use icon
  ),
  FocusTrack(
    id: '2',
    title: 'Creative Flow (Theta 6Hz)',
    category: 'Binaural',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    imageUrl: 'assets/images/focus_flow.png',
  ),
  FocusTrack(
    id: '3',
    title: 'Deep Relaxation (Delta 2Hz)',
    category: 'Meditation',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    imageUrl: 'assets/images/focus_relax.png',
  ),
];
