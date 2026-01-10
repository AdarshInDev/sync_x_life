import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FocusModePage extends StatelessWidget {
  const FocusModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    buildTimerSection(),
                    const SizedBox(height: 24),
                    buildCurrentFocusCard(),
                    const SizedBox(height: 24),
                    buildUpNextList(),
                    const SizedBox(height: 200), // Space for music bar + nav
                  ],
                ),
              ),
            ),
            // Music Bar (Positioned above Nav Bar? Or just part of flow?)
            // If I put it here, it will be at the bottom of the screen (behind Nav Bar).
            // So pad it up.
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: buildMusicBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Removed Back Button for Tab View
          Row(
            children: [
              Icon(Icons.timer, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Focus Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text(
                    "Daily Flow State",
                    style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "2h 15m",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTimerSection() {
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
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "LIVE SESSION",
                    style: TextStyle(
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
                // Placeholder for Liquid Animation
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.5, 0.5],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "25:00",
                      style: TextStyle(
                        fontSize: 64,
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "POMODORO 1/4",
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildControlButton(Icons.restart_alt),
              const SizedBox(width: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 24),
              buildControlButton(Icons.stop),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildControlButton(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, color: AppColors.textSecondary),
    );
  }

  Widget buildCurrentFocusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CURRENT FOCUS",
                style: TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.edit, size: 16, color: AppColors.textSubtle),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Finalize Q4 Marketing Strategy Deck",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              buildTag(
                "High Priority",
                Colors.red.withValues(alpha: 0.2),
                Colors.red,
              ),
              const SizedBox(width: 8),
              buildTag(
                "#Strategy",
                Colors.blue.withValues(alpha: 0.2),
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Subtasks",
                style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
              ),
              Text(
                "2/5",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.4,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget buildTag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildUpNextList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "UP NEXT",
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "3 Tasks",
                style: TextStyle(fontSize: 10, color: AppColors.textSubtle),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        buildTaskItem("Review Design System", "30m est"),
        const SizedBox(height: 8),
        buildTaskItem("Email Newsletter Draft", "45m est"),
      ],
    );
  }

  Widget buildTaskItem(String title, String duration) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.textSubtle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.drag_indicator, color: AppColors.textSubtle, size: 18),
        ],
      ),
    );
  }

  Widget buildMusicBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.surfaceDark, Colors.black]),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.headphones, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Ambient Focus Sound",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Playing: Binaural Beats (40Hz)",
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.skip_previous, color: Colors.white),
          const SizedBox(width: 16),
          Icon(Icons.pause, color: Colors.white),
          const SizedBox(width: 16),
          Icon(Icons.skip_next, color: Colors.white),
        ],
      ),
    );
  }
}
