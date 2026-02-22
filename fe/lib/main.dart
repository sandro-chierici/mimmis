import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/cost_repository.dart';
import 'data/repositories/user_repository.dart';
import 'features/home/home_notifier.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final client = ApiClient(baseUrl: AppConfig.baseUrl);
  final homeNotifier = HomeNotifier(
    userRepo: UserRepository(client),
    costRepo: CostRepository(client),
    prefs: prefs,
  );

  runApp(MimmisApp(homeNotifier: homeNotifier));
}

class MimmisApp extends StatelessWidget {
  const MimmisApp({super.key, required this.homeNotifier});

  final HomeNotifier homeNotifier;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => HomeScreen(notifier: homeNotifier),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Mimmis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
