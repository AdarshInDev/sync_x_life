import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
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
  final _pageController = PageController(initialPage: 2);
  final _controller = NotchBottomBarController(index: 2);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const FocusModePage(), // 0
    const HubDashboardAltPage(), // 1
    const ReflectionPage(), // 2
    const StatsPage(), // 3
    const SettingsPage(), // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Persistent Background Glow
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

            // Content
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),

            // Animated Bottom Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedNotchBottomBar(
                notchBottomBarController: _controller,
                color: AppColors.surfaceHighlight,
                showLabel: true,
                shadowElevation: 5,
                kBottomRadius: 28.0,
                notchColor: AppColors.primary,
                removeMargins: false,
                bottomBarWidth: MediaQuery.of(context).size.width,
                durationInMilliSeconds: 300,
                itemLabelStyle: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSubtle,
                ),
                elevation: 1,
                bottomBarItems: const [
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.timer_outlined,
                      color: AppColors.textSubtle,
                    ),
                    activeItem: Icon(
                      Icons.timer,
                      color: Colors.black,
                    ), // Black on Primary notch
                    itemLabel: 'Focus',
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.grid_view_outlined,
                      color: AppColors.textSubtle,
                    ),
                    activeItem: Icon(
                      Icons.grid_view_rounded,
                      color: Colors.black,
                    ),
                    itemLabel: 'Hub',
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.spa_outlined,
                      color: AppColors.textSubtle,
                    ),
                    activeItem: Icon(Icons.spa, color: Colors.black),
                    itemLabel: 'Ritual',
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.bar_chart_outlined,
                      color: AppColors.textSubtle,
                    ),
                    activeItem: Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.black,
                    ),
                    itemLabel: 'Stats',
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.settings_outlined,
                      color: AppColors.textSubtle,
                    ),
                    activeItem: Icon(Icons.settings, color: Colors.black),
                    itemLabel: 'Settings',
                  ),
                ],
                onTap: (index) {
                  _pageController.jumpToPage(index);
                },
                kIconSize: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension BlurExt on Widget {
  Widget blur(double sigma) {
    return this; // Placeholder
  }
}
