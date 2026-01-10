import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/focus/presentation/pages/focus_mode_page.dart';
import '../../../../features/reflection/presentation/pages/reflection_page.dart';
import '../../../../features/settings/presentation/pages/settings_page.dart';
import '../../../../features/stats/presentation/pages/stats_page.dart';
import 'hub_dashboard_alt_page.dart';

class MainHubPage extends StatefulWidget {
  const MainHubPage({super.key});

  @override
  State<MainHubPage> createState() => _MainHubPageState();
}

class _MainHubPageState extends State<MainHubPage> {
  int _currentIndex = 2; // Default to Ritual

  final List<Widget> _pages = [
    const FocusModePage(), // 0: Focus Mode (Timer & Tasks)
    const HubDashboardAltPage(), // 1: Hub (Main Dashboard)
    const ReflectionPage(), // 2: Ritual (Middle)
    const StatsPage(), // 3: Stats
    const SettingsPage(), // 4: Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Background Glow (Global)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  backgroundBlendMode: BlendMode.plus,
                ),
              ).blur(100),
            ),

            // Persistent Content
            Positioned.fill(
              child: IndexedStack(index: _currentIndex, children: _pages),
            ),

            // Bottom Navigation (Glass)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNav(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.timer_outlined, "Focus"),
          _buildNavItem(1, Icons.grid_view_rounded, "Hub"),
          _buildRitualNavItem(2), // Special Ritual Button
          _buildNavItem(3, Icons.bar_chart_rounded, "Stats"),
          _buildNavItem(4, Icons.settings_outlined, "Settings"),
        ],
      ),
    );
  }

  Widget _buildRitualNavItem(int index) {
    final bool isActive = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surfaceHighlight,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isActive
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.2),
              ),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 15,
                  ),
              ],
            ),
            child: Icon(
              Icons.spa,
              color: isActive ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ritual",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            decoration:
                isActive
                    ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    )
                    : null,
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSubtle,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

extension BlurExt on Widget {
  Widget blur(double sigma) {
    return this; // Placeholder
  }
}
