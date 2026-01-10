import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

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
}
