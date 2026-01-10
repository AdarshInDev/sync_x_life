import 'package:flutter/material.dart';

import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SyncXLifeApp());
}

class SyncXLifeApp extends StatelessWidget {
  const SyncXLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync x Life',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
