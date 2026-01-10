import 'package:flutter/material.dart';

import '../../../../core/models/data_models.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';

class HubDashboardAltPage extends StatefulWidget {
  const HubDashboardAltPage({super.key});

  @override
  State<HubDashboardAltPage> createState() => _HubDashboardAltPageState();
}

class _HubDashboardAltPageState extends State<HubDashboardAltPage> {
  final _supabaseService = SupabaseService();
  List<Habit> _habits = [];
  List<HabitLog> _todayLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final habits = await _supabaseService.getHabits();
      final logs = await _supabaseService.getTodayHabitLogs();

      if (mounted) {
        setState(() {
          _habits = habits;
          _todayLogs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  HabitLog? _getLogForHabit(String habitId) {
    try {
      return _todayLogs.firstWhere((log) => log.habitId == habitId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1410),
      child: SafeArea(
        bottom: false,
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceDark,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildActivityMap(),
                        const SizedBox(height: 16),
                        _buildBrightDaySection(),
                        const SizedBox(height: 16),
                        _buildHabitsGrid(),
                        const SizedBox(height: 24),
                        _buildReflectionInput(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bolt, color: Color(0xFF00E054), size: 16),
                SizedBox(width: 4),
                Text(
                  "DAILY MOMENTUM",
                  style: TextStyle(
                    color: Color(0xFF00E054),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "The Pulse",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormattedDate(),
              style: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF12211A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.generating_tokens,
                color: Colors.orange[400],
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                "3 Skips",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day} • ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildActivityMap() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Activity Map",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E054).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "+12% vs last month",
                  style: TextStyle(
                    color: Color(0xFF00E054),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (colIndex) {
              return Column(
                children: List.generate(7, (rowIndex) {
                  final opacity =
                      (rowIndex + colIndex) % 2 == 0
                          ? 0.1
                          : ((rowIndex * colIndex) % 5 + 1) * 0.2;
                  final isBlank = (rowIndex + colIndex) % 3 == 0;
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color:
                          isBlank
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(
                                0xFF00E054,
                              ).withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                    .map(
                      (day) => Text(
                        day.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightDaySection() {
    final completedCount = _todayLogs.where((log) => log.isCompleted).length;
    final totalCount = _habits.length;
    final percentage = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Bright Day",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                "${(percentage * 100).toInt()}%",
                style: const TextStyle(
                  color: Color(0xFF00E054),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00E054),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$completedCount of $totalCount habits completed",
                style: const TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 10,
                ),
              ),
              Text(
                percentage >= 0.8 ? "Almost there!" : "Keep going!",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsGrid() {
    return Column(
      children: [
        for (int i = 0; i < _habits.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: _buildHabitCard(_habits[i])),
                const SizedBox(width: 16),
                if (i + 1 < _habits.length)
                  Expanded(child: _buildHabitCard(_habits[i + 1]))
                else
                  Expanded(child: _buildAddHabitCard()),
              ],
            ),
          ),
        if (_habits.length % 2 == 0)
          Row(
            children: [
              Expanded(child: _buildAddHabitCard()),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),
      ],
    );
  }

  Widget _buildHabitCard(Habit habit) {
    return HabitCard(
      habit: habit,
      log: _getLogForHabit(habit.id),
      onSave: _loadData,
    );
  }

  Widget _buildAddHabitCard() {
    return GestureDetector(
      onTap: _showAddHabitDialog,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF12211A).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.textSubtle),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add Habit",
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... existing code ...

  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    final goalController = TextEditingController(text: '1');
    String selectedIcon = 'star';
    String selectedColor = '#00E054';
    String selectedUnit = 'times';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: const Color(0xFF12211A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Add New Habit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Habit Name',
                            labelStyle: const TextStyle(
                              color: AppColors.textSubtle,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: goalController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Goal',
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSubtle,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            DropdownButton<String>(
                              value: selectedUnit,
                              dropdownColor: const Color(0xFF12211A),
                              style: const TextStyle(color: Colors.white),
                              items:
                                  ['times', 'hours', 'min', 'L', 'km'].map((
                                    unit,
                                  ) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    );
                                  }).toList(),
                              onChanged:
                                  (value) =>
                                      setState(() => selectedUnit = value!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Icon:',
                          style: TextStyle(color: AppColors.textSubtle),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              [
                                'star',
                                'emoji_events',
                                'water_drop',
                                'menu_book',
                                'self_improvement',
                                'fitness_center',
                              ].map((icon) {
                                return GestureDetector(
                                  onTap:
                                      () => setState(() => selectedIcon = icon),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedIcon == icon
                                              ? AppColors.primary.withValues(
                                                alpha: 0.2,
                                              )
                                              : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            selectedIcon == icon
                                                ? AppColors.primary
                                                : Colors.transparent,
                                      ),
                                    ),
                                    child: Icon(
                                      _getIconData(icon),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Color:',
                          style: TextStyle(color: AppColors.textSubtle),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              [
                                '#00E054',
                                '#F59E0B',
                                '#3B82F6',
                                '#8B5CF6',
                                '#EC4899',
                                '#10B981',
                              ].map((color) {
                                return GestureDetector(
                                  onTap:
                                      () =>
                                          setState(() => selectedColor = color),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getColor(color),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selectedColor == color
                                                ? Colors.white
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSubtle),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          await _supabaseService.createHabit(
                            title: titleController.text,
                            icon: selectedIcon,
                            color: selectedColor,
                            goalValue:
                                double.tryParse(goalController.text) ?? 1.0,
                            goalUnit: selectedUnit,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _loadData();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Create'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildReflectionInput() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.2),
            const Color(0xFF12211A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00E054).withValues(alpha: 0.2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF12211A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E054),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "REFLECTION READY",
                      style: TextStyle(
                        color: Color(0xFF00E054),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "2 min",
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "What stopped you from flowing today?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Identify the blockers to ensure a 1% better tomorrow.",
              style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Type here or use voice...",
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E054),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Icon(Icons.mic, color: Colors.black, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'water_drop':
        return Icons.water_drop;
      case 'menu_book':
        return Icons.menu_book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.star;
    }
  }

  Color _getColor(String? colorHex) {
    if (colorHex == null) return AppColors.primary;
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}

class HabitCard extends StatefulWidget {
  final Habit habit;
  final HabitLog? log;
  final VoidCallback onSave;

  const HabitCard({
    super.key,
    required this.habit,
    required this.log,
    required this.onSave,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  late double _currentValue;
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.log?.currentValue ?? 0.0;
  }

  @override
  void didUpdateWidget(covariant HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.log != widget.log) {
      _currentValue = widget.log?.currentValue ?? 0.0;
    }
  }

  Color _getColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'water_drop':
        return Icons.water_drop;
      case 'menu_book':
        return Icons.menu_book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(widget.habit.color ?? '#00E054');
    final iconData = _getIconData(widget.habit.icon);
    final isDone = _currentValue >= widget.habit.goalValue;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.habit.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_currentValue.toStringAsFixed(1)}${widget.habit.goalUnit} / ${widget.habit.goalValue}${widget.habit.goalUnit}",
                    style: const TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 12,
                    ),
                  ),
                  if (isDone)
                    Text(
                      "Done",
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Interactive Slider
              SizedBox(
                height: 24, // Constrain height to fit
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: color,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    overlayColor: color.withValues(alpha: 0.2),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: _currentValue.clamp(
                      0.0,
                      widget.habit.goalValue,
                    ), // Ensure valid range
                    min: 0.0,
                    max: widget.habit.goalValue, // Max is goal
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                      });
                    },
                    onChangeEnd: (value) async {
                      await _supabaseService.setHabitLogValue(
                        widget.habit.id,
                        value,
                      );
                      widget
                          .onSave(); // Trigger parent refresh (Bright Day stats)
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
