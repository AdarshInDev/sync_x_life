import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/focus/data/models/playlist_model.dart';
import '../models/data_models.dart';

class SupabaseService {
  SupabaseClient get client => Supabase.instance.client;

  // --- Auth ---
  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    // Requires Google Cloud + Supabase config.
    // Ensure you have added the SHA-1 fingerprint to Supabase > Auth > Google.
    await client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // --- Profiles ---
  Future<UserProfile?> getProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final data =
          await client.from('profiles').select().eq('id', user.id).single();
      return UserProfile.fromJson(data);
    } catch (e) {
      // Handle error or return null if not found
      return null;
    }
  }

  // --- Habits ---
  Future<List<Habit>> getHabits() async {
    final user = currentUser;
    if (user == null) return [];

    final data = await client
        .from('habits')
        .select()
        .eq('user_id', user.id)
        .eq('is_archived', false);

    return (data as List).map((e) => Habit.fromJson(e)).toList();
  }

  Future<List<HabitLog>> getTodayHabitLogs() async {
    final user = currentUser;
    if (user == null) return [];

    final today = DateTime.now().toIso8601String().split('T')[0];
    final data = await client
        .from('habit_logs')
        .select()
        .eq('user_id', user.id)
        .eq('date', today);

    return (data as List).map((e) => HabitLog.fromJson(e)).toList();
  }

  Future<void> updateHabitLog(String habitId, double value) async {
    final user = currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];

    // Check if log exists for today
    final existing =
        await client
            .from('habit_logs')
            .select()
            .eq('habit_id', habitId)
            .eq('user_id', user.id)
            .eq('date', today)
            .maybeSingle();

    // Get habit to check goal
    final habitData =
        await client.from('habits').select().eq('id', habitId).single();
    final habit = Habit.fromJson(habitData);

    if (existing != null) {
      // Update existing log
      final newValue = (existing['current_value'] as num).toDouble() + value;
      await client
          .from('habit_logs')
          .update({
            'current_value': newValue,
            'is_completed': newValue >= habit.goalValue,
          })
          .eq('id', existing['id']);
    } else {
      // Create new log
      await client.from('habit_logs').insert({
        'habit_id': habitId,
        'user_id': user.id,
        'date': today,
        'current_value': value,
        'is_completed': value >= habit.goalValue,
      });
    }
  }

  Future<void> setHabitLogValue(String habitId, double value) async {
    final user = currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];

    // Fetch all matching logs to check for duplicates
    final existingList = await client
        .from('habit_logs')
        .select()
        .eq('habit_id', habitId)
        .eq('user_id', user.id)
        .eq('date', today);

    final habitData =
        await client.from('habits').select().eq('id', habitId).single();
    final habit = Habit.fromJson(habitData);

    if (existingList.isNotEmpty) {
      // Use the first one as the master
      final firstLogOfToday = existingList[0];
      await client
          .from('habit_logs')
          .update({
            'current_value': value,
            'is_completed': value >= habit.goalValue, // Recalculate completion
          })
          .eq('id', firstLogOfToday['id']);

      // Deduplicate: Delete any extra logs that might have been created erroneously
      if (existingList.length > 1) {
        for (int i = 1; i < existingList.length; i++) {
          await client
              .from('habit_logs')
              .delete()
              .eq('id', existingList[i]['id']);
        }
      }
    } else {
      await client.from('habit_logs').insert({
        'habit_id': habitId,
        'user_id': user.id,
        'date': today,
        'current_value': value,
        'is_completed': value >= habit.goalValue,
      });
    }
  }

  Future<void> createHabit({
    required String title,
    required String icon,
    required String color,
    required double goalValue,
    required String goalUnit,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await client.from('habits').insert({
      'user_id': user.id,
      'title': title,
      'icon': icon,
      'color': color,
      'goal_value': goalValue,
      'goal_unit': goalUnit,
      'is_archived': false,
    });
  }

  // --- Focus ---
  Future<void> logFocusSession(FocusSession session) async {
    await client.from('focus_sessions').insert({
      'user_id': session.userId,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime.toIso8601String(),
      'duration_minutes': session.durationMinutes,
      'task_id': session.taskId,
    });
  }

  Future<List<FocusSession>> getFocusSessions({int limit = 10}) async {
    final user = currentUser;
    if (user == null) return [];

    final data = await client
        .from('focus_sessions')
        .select()
        .eq('user_id', user.id)
        .order('start_time', ascending: false)
        .limit(limit);

    return (data as List).map((e) => FocusSession.fromJson(e)).toList();
  }

  // --- Tasks ---
  Future<List<Task>> getTasks() async {
    final user = currentUser;
    if (user == null) return [];

    final data = await client
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .eq('is_completed', false)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<void> createTask({
    required String title,
    required int estimatedMinutes,
    int estimatedSeconds = 0,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await client.from('tasks').insert({
      'user_id': user.id,
      'title': title,
      'estimated_minutes': estimatedMinutes,
      'estimated_seconds': estimatedSeconds,
      'is_completed': false,
      'sort_order': 0,
    });
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    int? estimatedMinutes,
    int? estimatedSeconds,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (estimatedMinutes != null) {
      updates['estimated_minutes'] = estimatedMinutes;
    }
    if (estimatedSeconds != null) {
      updates['estimated_seconds'] = estimatedSeconds;
    }

    if (updates.isEmpty) return;

    await client.from('tasks').update(updates).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await client.from('tasks').delete().eq('id', taskId);
  }

  Future<void> updateTaskOrder(List<Task> tasks) async {
    // This is not efficient for large lists but fine for small personal task lists
    for (int i = 0; i < tasks.length; i++) {
      await client
          .from('tasks')
          .update({'sort_order': i})
          .eq('id', tasks[i].id);
    }
  }

  // --- Reflection ---
  Future<void> saveReflection(Reflection reflection) async {
    await client.from('reflections').insert({
      'user_id': reflection.userId,
      'date': reflection.date.toIso8601String().split('T')[0],
      'mood_score': reflection.moodScore,
      'productivity_score': reflection.productivityScore,
      'blocker_note': reflection.blockerNote,
      'audio_url': reflection.audioUrl,
      'title': reflection.title,
      'takeaways': reflection.takeaways,
      'highlight': reflection.highlight,
      'blocker': reflection.blocker,
      'improvement': reflection.improvement,
    });
  }

  Future<List<Reflection>> getReflections({int limit = 30}) async {
    final user = currentUser;
    if (user == null) return [];

    final data = await client
        .from('reflections')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .limit(limit);

    return (data as List).map((e) => Reflection.fromJson(e)).toList();
  }

  Future<Reflection?> getReflectionByDate(DateTime date) async {
    final user = currentUser;
    if (user == null) return null;

    final dateStr = date.toIso8601String().split('T')[0];
    final data =
        await client
            .from('reflections')
            .select()
            .eq('user_id', user.id)
            .eq('date', dateStr)
            .maybeSingle();

    return data != null ? Reflection.fromJson(data) : null;
  }

  Future<void> deleteReflection(String reflectionId) async {
    final user = currentUser;
    if (user == null) return;

    // Get reflection to check for audio file
    final data =
        await client
            .from('reflections')
            .select()
            .eq('id', reflectionId)
            .maybeSingle();

    if (data == null) return;

    final reflection = Reflection.fromJson(data);
    if (reflection.audioUrl != null) {
      await deleteAudioFile(reflection.audioUrl!);
    }

    await client.from('reflections').delete().eq('id', reflectionId);
  }

  // --- Audio Storage ---
  /// Upload audio file to Supabase Storage and return public URL
  Future<String?> uploadAudioFile(String filePath, String userId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('Audio file does not exist: $filePath');
        return null;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.m4a';
      final storagePath = 'reflections/$fileName';

      // Upload file to storage bucket
      await client.storage
          .from('reflection-audio')
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl = client.storage
          .from('reflection-audio')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading audio file: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Delete audio file from storage
  Future<void> deleteAudioFile(String audioUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(audioUrl);
      final pathSegments = uri.pathSegments;
      final storagePath = pathSegments
          .sublist(pathSegments.indexOf('reflections'))
          .join('/');

      await client.storage.from('reflection-audio').remove([storagePath]);
    } catch (e) {
      print('Error deleting audio file: $e');
    }
  }

  // --- Playlists ---
  Future<void> createPlaylist(String name) async {
    final user = currentUser;
    if (user == null) return;

    await client.from('playlists').insert({'user_id': user.id, 'name': name});
  }

  Future<List<Playlist>> getPlaylists() async {
    final user = currentUser;
    if (user == null) return [];

    final data = await client
        .from('playlists')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Playlist.fromJson(e)).toList();
  }

  Future<void> addToPlaylist({
    required String playlistId,
    required String videoId,
    required String title,
    required String author,
    String? imageUrl,
  }) async {
    // Check if song already exists in this playlist
    final existing =
        await client
            .from('playlist_items')
            .select()
            .eq('playlist_id', playlistId)
            .eq('video_id', videoId)
            .maybeSingle();

    if (existing != null) {
      throw Exception('This song is already in the playlist');
    }

    await client.from('playlist_items').insert({
      'playlist_id': playlistId,
      'video_id': videoId,
      'title': title,
      'author': author,
      'image_url': imageUrl,
      'sort_order': 0,
    });
  }

  Future<List<PlaylistItem>> getPlaylistItems(String playlistId) async {
    final data = await client
        .from('playlist_items')
        .select()
        .eq('playlist_id', playlistId)
        .order('sort_order', ascending: true)
        .order('added_at', ascending: true);

    return (data as List).map((e) => PlaylistItem.fromJson(e)).toList();
  }

  Future<void> updatePlaylistItemsOrder(List<PlaylistItem> items) async {
    for (int i = 0; i < items.length; i++) {
      await client
          .from('playlist_items')
          .update({'sort_order': i})
          .eq('id', items[i].id);
    }
  }

  // --- Ritual System ---

  /// Get user's ritual configuration
  Future<RitualConfig> getRitualConfig() async {
    final user = currentUser;
    if (user == null) {
      return RitualConfig(
        ritualsPerDay: 1,
        ritualTitles: RitualConfig.getDefaultTitles(1),
      );
    }

    final data =
        await client
            .from('profiles')
            .select('rituals_per_day, ritual_titles')
            .eq('id', user.id)
            .single();

    return RitualConfig.fromJson(data);
  }

  /// Update user's ritual configuration
  Future<void> updateRitualConfig(int count, Map<String, String> titles) async {
    final user = currentUser;
    if (user == null) return;

    await client
        .from('profiles')
        .update({'rituals_per_day': count, 'ritual_titles': titles})
        .eq('id', user.id);
  }

  /// Get current ritual slot based on time and user's ritual count
  String getCurrentRitualSlot(int ritualsPerDay) {
    final now = DateTime.now();
    final hour = now.hour;

    switch (ritualsPerDay) {
      case 1:
        return 'daily';
      case 2:
        return hour < 12 ? 'morning' : 'evening';
      case 3:
        if (hour < 8) return 'morning';
        if (hour < 16) return 'afternoon';
        return 'evening';
      case 4:
        if (hour < 6) return 'morning';
        if (hour < 12) return 'afternoon';
        if (hour < 18) return 'evening';
        return 'night';
      default:
        return 'daily';
    }
  }

  /// Check if a ritual slot is still available (not expired)
  bool isRitualSlotAvailable(String slot, int ritualsPerDay) {
    final now = DateTime.now();
    final hour = now.hour;

    switch (ritualsPerDay) {
      case 1:
        return true; // Daily ritual available all day
      case 2:
        if (slot == 'morning') return hour < 12;
        if (slot == 'evening') return hour >= 12;
        return false;
      case 3:
        if (slot == 'morning') return hour < 8;
        if (slot == 'afternoon') return hour >= 8 && hour < 16;
        if (slot == 'evening') return hour >= 16;
        return false;
      case 4:
        if (slot == 'morning') return hour < 6;
        if (slot == 'afternoon') return hour >= 6 && hour < 12;
        if (slot == 'evening') return hour >= 12 && hour < 18;
        if (slot == 'night') return hour >= 18;
        return false;
      default:
        return true;
    }
  }

  /// Complete a ritual
  Future<void> completeRitual(String slot, {DateTime? date}) async {
    final user = currentUser;
    if (user == null) return;

    final targetDate = date ?? DateTime.now();
    final dateStr = targetDate.toIso8601String().split('T')[0];

    await client.from('ritual_completions').upsert({
      'user_id': user.id,
      'date': dateStr,
      'ritual_slot': slot,
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,date,ritual_slot');
  }

  /// Mark a ritual as missed
  Future<void> markRitualMissed(String slot, {DateTime? date}) async {
    final user = currentUser;
    if (user == null) return;

    final targetDate = date ?? DateTime.now();
    final dateStr = targetDate.toIso8601String().split('T')[0];

    // Check if already completed
    final existing =
        await client
            .from('ritual_completions')
            .select()
            .eq('user_id', user.id)
            .eq('date', dateStr)
            .eq('ritual_slot', slot)
            .maybeSingle();

    if (existing == null) {
      await client.from('ritual_completions').insert({
        'user_id': user.id,
        'date': dateStr,
        'ritual_slot': slot,
        'status': 'missed',
      });
    }
  }

  /// Get ritual completions for a specific date
  Future<List<RitualCompletion>> getRitualCompletions({DateTime? date}) async {
    final user = currentUser;
    if (user == null) return [];

    final targetDate = date ?? DateTime.now();
    final dateStr = targetDate.toIso8601String().split('T')[0];

    final data = await client
        .from('ritual_completions')
        .select()
        .eq('user_id', user.id)
        .eq('date', dateStr);

    return (data as List).map((e) => RitualCompletion.fromJson(e)).toList();
  }

  /// Check and mark missed rituals for today
  Future<void> checkAndMarkMissedRituals() async {
    final config = await getRitualConfig();
    final completions = await getRitualCompletions();
    final completedSlots = completions.map((c) => c.ritualSlot).toSet();

    final allSlots = config.getSlotKeys();
    for (final slot in allSlots) {
      if (!completedSlots.contains(slot) &&
          !isRitualSlotAvailable(slot, config.ritualsPerDay)) {
        await markRitualMissed(slot);
      }
    }
  }

  /// Get ritual stats for a date range
  Future<Map<String, int>> getRitualStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = currentUser;
    if (user == null) return {'completed': 0, 'missed': 0};

    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];

    final data = await client
        .from('ritual_completions')
        .select()
        .eq('user_id', user.id)
        .gte('date', startStr)
        .lte('date', endStr);

    final completions =
        (data as List).map((e) => RitualCompletion.fromJson(e)).toList();

    return {
      'completed': completions.where((c) => c.isCompleted).length,
      'missed': completions.where((c) => c.isMissed).length,
    };
  }
}
