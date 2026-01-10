import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HubDashboardAltPage extends StatelessWidget {
  const HubDashboardAltPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1410), // Background Dark from design
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildActivityMap(),
              const SizedBox(height: 16),
              _buildBrightDaySection(),
              const SizedBox(height: 16),
              _buildHabitStartGrid(), // Deep Work & Hydration
              const SizedBox(height: 16),
              _buildEveningReadingCard(),
              const SizedBox(height: 16),
              _buildHabitEndGrid(), // Mindful & Add Habit
              const SizedBox(height: 24),
              _buildReflectionInput(),
              const SizedBox(height: 120), // Bottom padding for nav
            ],
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
            const Text(
              "Thursday, Oct 24 • 8:00 PM",
              style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
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

  Widget _buildActivityMap() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A), // Card Dark
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
          // Heatmap Grid Mockup
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (colIndex) {
              return Column(
                children: List.generate(7, (rowIndex) {
                  // Random opacity for "green" effect
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A), // Card Dark
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                "Bright Day",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                "82%",
                style: TextStyle(
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
              widthFactor: 0.82,
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
            children: const [
              Text(
                "Keep the streak alive (12 days)",
                style: TextStyle(color: AppColors.textSubtle, fontSize: 10),
              ),
              Text(
                "Almost there",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStartGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildHabitCard(
            title: "Deep Work",
            progressText: "4h / 4h goal",
            progress: 1.0,
            icon: Icons.emoji_events,
            color: Colors.yellow[700]!,
            isDone: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHabitCard(
            title: "Hydration",
            progressText: "1.5L / 3L",
            progress: 0.5,
            icon: Icons.water_drop,
            color: Colors.blue[400]!,
            showAddButton: true,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitEndGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildHabitCard(
            title: "Mindful",
            progressText: "10m / 15m",
            progress: 0.66,
            icon: Icons.self_improvement,
            color: Colors.pink[400]!,
          ),
        ),
        const SizedBox(width: 16),
        // Add Habit Card
        Expanded(
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF12211A).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                style: BorderStyle.solid, // Should be dashed ideally
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
        ),
      ],
    );
  }

  Widget _buildHabitCard({
    required String title,
    required String progressText,
    required double progress,
    required IconData icon,
    required Color color,
    bool isDone = false,
    bool showAddButton = false,
  }) {
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
                child: Icon(icon, color: color, size: 20),
              ),
              if (showAddButton)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.add, color: color, size: 16),
                )
              else
                Icon(Icons.more_horiz, color: AppColors.textSubtle, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                progressText,
                style: const TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isDone || progress > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      isDone ? "Done" : "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEveningReadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12211A), // Card Dark
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Evening Reading",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Atomic Habits • Chapter 4",
                        style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColors.textSubtle,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2E24).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Time remaining today",
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
                Text(
                  "25:00",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Space Grotesk',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
}
