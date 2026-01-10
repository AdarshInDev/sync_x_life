import 'package:flutter/material.dart';

import '../../features/focus/presentation/pages/focus_mode_page.dart';
import '../../features/home/presentation/pages/main_hub_page.dart';
import '../../features/reflection/presentation/pages/reflection_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String focus = '/focus';
  static const String reflection = '/reflection';
  static const String stats = '/stats';
  static const String settingsRoute = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainHubPage(),
          settings: settings,
        );
      case focus:
        return MaterialPageRoute(
          builder: (_) => const FocusModePage(),
          settings: settings,
        );
      case reflection:
        return MaterialPageRoute(
          builder: (_) => const ReflectionPage(),
          settings: settings,
        );
      case stats:
        return MaterialPageRoute(
          builder: (_) => const StatsPage(),
          settings: settings,
        );
      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
