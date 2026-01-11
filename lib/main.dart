import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_routes.dart';
import 'core/services/supabase_service.dart';
import 'core/services/theme_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/focus/services/focus_music_service.dart';
import 'features/home/presentation/pages/main_hub_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://auyckjjsrkudjhvlpxzt.supabase.co',
    anonKey: 'sb_publishable_hyPZMBpNsNRA5NFEWoU_6w_1FRhbALp',
  );

  await initAudioService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const SyncXLifeApp(),
    ),
  );
}

class SyncXLifeApp extends StatelessWidget {
  const SyncXLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          key: ValueKey(
            themeService.currentTheme.type,
          ), // Force rebuild on theme change
          title: 'Sync x Life',
          debugShowCheckedModeBanner: false,
          theme: themeService.currentTheme.toThemeData(),
          home: const AuthGate(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const MainHubPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
