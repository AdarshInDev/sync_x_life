class UserProfile {
  final String id;
  final String? username;
  final String? avatarUrl;
  final DateTime createdAt;
  final int streakCount;
  final int totalFocusMinutes;
  final int skipsRemaining;

  UserProfile({
    required this.id,
    this.username,
    this.avatarUrl,
    required this.createdAt,
    this.streakCount = 0,
    this.totalFocusMinutes = 0,
    this.skipsRemaining = 3,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      streakCount: json['streak_count'] ?? 0,
      totalFocusMinutes: json['total_focus_minutes'] ?? 0,
      skipsRemaining: json['skips_remaining'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'streak_count': streakCount,
      'total_focus_minutes': totalFocusMinutes,
      'skips_remaining': skipsRemaining,
    };
  }
}

class Habit {
  final String id;
  final String userId;
  final String title;
  final String? icon;
  final String? color;
  final double goalValue;
  final String goalUnit;
  final bool isArchived;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.icon,
    this.color,
    this.goalValue = 1.0,
    this.goalUnit = 'times',
    this.isArchived = false,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      icon: json['icon'],
      color: json['color'],
      goalValue: (json['goal_value'] as num).toDouble(),
      goalUnit: json['goal_unit'] ?? 'times',
      isArchived: json['is_archived'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'icon': icon,
      'color': color,
      'goal_value': goalValue,
      'goal_unit': goalUnit,
      'is_archived': isArchived,
    };
  }
}

class HabitLog {
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  final double currentValue;
  final bool isCompleted;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.currentValue,
    required this.isCompleted,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'],
      habitId: json['habit_id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      currentValue: (json['current_value'] as num).toDouble(),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'current_value': currentValue,
      'is_completed': isCompleted,
    };
  }
}

class FocusSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String? taskId;

  FocusSession({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.taskId,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'],
      userId: json['user_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      durationMinutes: json['duration_minutes'],
      taskId: json['task_id'],
    );
  }
}

class Reflection {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? createdAt;
  final int? moodScore;
  final int? productivityScore;
  final String? blockerNote;
  final String? audioUrl;
  final String? title;
  final List<String>? takeaways;
  final String? highlight;
  final String? blocker;
  final String? improvement;

  Reflection({
    required this.id,
    required this.userId,
    required this.date,
    this.createdAt,
    this.moodScore,
    this.productivityScore,
    this.blockerNote,
    this.audioUrl,
    this.title,
    this.takeaways,
    this.highlight,
    this.blocker,
    this.improvement,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) {
    DateTime? createdAtIST;
    if (json['created_at'] != null) {
      final utcTime = DateTime.parse(json['created_at']);
      // Convert UTC to IST (UTC + 5:30)
      createdAtIST = utcTime.add(const Duration(hours: 5, minutes: 30));
    }

    return Reflection(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      createdAt: createdAtIST,
      moodScore: json['mood_score'],
      productivityScore: json['productivity_score'],
      blockerNote: json['blocker_note'],
      audioUrl: json['audio_url'],
      title: json['title'],
      takeaways:
          json['takeaways'] != null
              ? List<String>.from(json['takeaways'])
              : null,
      highlight: json['highlight'],
      blocker: json['blocker'],
      improvement: json['improvement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
      'mood_score': moodScore,
      'productivity_score': productivityScore,
      'blocker_note': blockerNote,
      'audio_url': audioUrl,
      'title': title,
      'takeaways': takeaways,
      'highlight': highlight,
      'blocker': blocker,
      'improvement': improvement,
    };
  }
}

class Task {
  final String id;
  final String userId;
  final String title;
  final int estimatedMinutes;
  final int estimatedSeconds;
  final bool isCompleted;
  final DateTime createdAt;
  final int sortOrder;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.estimatedMinutes,
    this.estimatedSeconds = 0,
    required this.isCompleted,
    required this.createdAt,
    this.sortOrder = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 0,
      estimatedSeconds: (json['estimated_seconds'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'estimated_minutes': estimatedMinutes,
      'estimated_seconds': estimatedSeconds,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }
}
