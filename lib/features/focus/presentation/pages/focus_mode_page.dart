import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/data_models.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../services/focus_music_service.dart';
import '../widgets/focus_player_widget.dart';
import 'online_music_page.dart';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  final _supabaseService = SupabaseService();

  // State
  List<Task> _tasks = [];
  Task? _currentTask;
  bool _isLoading = true;
  bool _isPomodoroMode = false; // Default to Focus (Task) Mode

  // Timer state
  int _remainingSeconds = 25 * 60; // 25 minutes
  bool _isRunning = false;
  Timer? _timer;
  DateTime? _sessionStartTime;

  void _toggleMode(bool isPomodoro) {
    if (_isRunning) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: const Text(
                'Session in Progress',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Switching modes will reset your current timer. Are you sure you want to continue?',
                style: TextStyle(color: AppColors.textSubtle),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _performModeSwitch(isPomodoro);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Switch'),
                ),
              ],
            ),
      );
    } else {
      _performModeSwitch(isPomodoro);
    }
  }

  void _performModeSwitch(bool isPomodoro) {
    setState(() {
      _isPomodoroMode = isPomodoro;
      _isRunning = false;
      _timer?.cancel();
      _sessionStartTime = null;

      if (_isPomodoroMode) {
        _remainingSeconds = 25 * 60;
      } else {
        // Sync with current task or default to 25
        _remainingSeconds =
            (_currentTask?.estimatedMinutes ?? 25) * 60 +
            (_currentTask?.estimatedSeconds ?? 0);
      }
    });
  }

  // ... (dispose, startTimer etc need updates, but let's do header first) ...

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.timer, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Deep Work",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Stats
              Row(
                children: const [
                  Text(
                    "Daily Flow",
                    style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "2h 15m",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Custom Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleMode(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            !_isPomodoroMode
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Focus Session",
                          style: TextStyle(
                            color:
                                !_isPomodoroMode
                                    ? AppColors.primary
                                    : AppColors.textSubtle,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleMode(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            _isPomodoroMode
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Pomodoro",
                          style: TextStyle(
                            color:
                                _isPomodoroMode
                                    ? AppColors.primary
                                    : AppColors.textSubtle,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    FocusMusicService().init();
  }

  Future<void> _loadTasks() async {
    final tasks = await _supabaseService.getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
        // Auto-select first task if none selected
        if (_currentTask == null && _tasks.isNotEmpty) {
          _currentTask = _tasks.first;
          if (!_isPomodoroMode) {
            _remainingSeconds =
                (_currentTask?.estimatedMinutes ?? 25) * 60 +
                (_currentTask?.estimatedSeconds ?? 0);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _sessionStartTime ??= DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _sessionStartTime = null;
      if (_isPomodoroMode) {
        _remainingSeconds = 25 * 60;
      } else {
        _remainingSeconds =
            (_currentTask?.estimatedMinutes ?? 25) * 60 +
            (_currentTask?.estimatedSeconds ?? 0);
      }
    });
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    if (_sessionStartTime != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_sessionStartTime!).inMinutes;

      final session = FocusSession(
        id: '',
        userId: _supabaseService.currentUser!.id,
        startTime: _sessionStartTime!,
        endTime: endTime,
        durationMinutes: duration > 0 ? duration : 1, // Minimum 1 min
        taskId: _currentTask?.id,
      );

      try {
        await _supabaseService.logFocusSession(session);

        // Auto-complete task in Focus Mode
        if (!_isPomodoroMode && _currentTask != null) {
          await _supabaseService.deleteTask(_currentTask!.id);
          _loadTasks(); // Refresh list
          _currentTask = null; // Clear selection
          _remainingSeconds = 25 * 60; // Reset
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Focus session completed!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        // Handle error
      }
    }

    _resetTimer();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        bottom: false,
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadTasks,
                        color: AppColors.primary,
                        backgroundColor: AppColors.surfaceDark,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildTimerSection(),
                              if (!_isPomodoroMode) ...[
                                const SizedBox(height: 24),
                                _buildCurrentFocusCard(),
                                const SizedBox(height: 24),
                                _buildUpNextList(),
                              ],
                              const SizedBox(height: 200),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildMusicPlayer(),
                    const SizedBox(height: 110), // Bottom Nav Bar padding
                  ],
                ),
      ),
    );
  }

  Widget _buildMusicPlayer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OnlineMusicPage()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.cloud_queue, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  "Listen to Music Online",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const FocusPlayerWidget(),
      ],
    );
  }

  Widget _buildTimerSection() {
    final progress = 1 - (_remainingSeconds / (25 * 60));

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          _isRunning ? AppColors.error : AppColors.textSubtle,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRunning ? "LIVE SESSION" : "READY",
                    style: const TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Circular Timer
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: AppColors.surfaceHighlight, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress indicator
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 64,
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning ? "Focus Time" : "Ready to Focus",
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning) ...[
                ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.play_arrow, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Start",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                IconButton(
                  onPressed: _pauseTimer,
                  icon: const Icon(
                    Icons.pause,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(
                    Icons.stop,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFocusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.task_alt,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Current Focus",
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentTask?.title ?? "Select or Add a Task",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textSubtle),
        ],
      ),
    );
  }

  Widget _buildUpNextList() {
    // Filter out current task from the list
    final upNextTasks = _tasks.where((t) => t.id != _currentTask?.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Up Next",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (upNextTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "No upcoming tasks. Add one!",
              style: TextStyle(color: AppColors.textSubtle),
            ),
          ),
        if (upNextTasks.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) async {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final task = upNextTasks.removeAt(oldIndex);
                  upNextTasks.insert(newIndex, task);
                });
                await _supabaseService.updateTaskOrder(upNextTasks);
                _loadTasks();
              },
              itemCount: upNextTasks.length,
              itemBuilder: (context, index) {
                final task = upNextTasks[index];
                return Container(
                  key: ValueKey(task.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentTask = task;
                            if (!_isPomodoroMode) {
                              _remainingSeconds =
                                  task.estimatedMinutes * 60 +
                                  task.estimatedSeconds;
                            }
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.textSubtle,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentTask = task;
                              if (!_isPomodoroMode) {
                                _remainingSeconds =
                                    task.estimatedMinutes * 60 +
                                    task.estimatedSeconds;
                              }
                            });
                          },
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "${task.estimatedMinutes}m ${task.estimatedSeconds > 0 ? '${task.estimatedSeconds}s' : ''}",
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.textSubtle,
                        ),
                        onPressed: () => _showEditTaskDialog(task),
                      ),
                      const Icon(
                        Icons.drag_handle,
                        color: AppColors.textSubtle,
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddTaskDialog() {
    _showTaskBottomSheet();
  }

  void _showEditTaskDialog(Task task) {
    _showTaskBottomSheet(task: task);
  }

  void _showTaskBottomSheet({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    Duration duration = Duration(
      minutes: task?.estimatedMinutes ?? 25,
      seconds: task?.estimatedSeconds ?? 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task == null ? 'New Focus Task' : 'Edit Task',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title Input
                TextField(
                  controller: titleController,
                  autofocus: task == null,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'What are you focusing on?',
                    hintStyle: const TextStyle(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Duration",
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Native-style Picker
                Expanded(
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hms,
                    initialTimerDuration: duration,
                    onTimerDurationChanged: (newDuration) {
                      duration = newDuration;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Action Button
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final minutes = duration.inMinutes;
                      final seconds = duration.inSeconds % 60;
                      // Ensure at least 1 min or 1 sec is set, otherwise default to 1 min?
                      // Actually, functionality allows seconds-only tasks.

                      if (task == null) {
                        await _supabaseService.createTask(
                          title: titleController.text,
                          estimatedMinutes: minutes,
                          estimatedSeconds: seconds,
                        );
                      } else {
                        await _supabaseService.updateTask(
                          taskId: task.id,
                          title: titleController.text,
                          estimatedMinutes: minutes,
                          estimatedSeconds: seconds,
                        );
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        _loadTasks();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    task == null ? 'Start Task' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Keyboard padding
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
    );
  }
}
