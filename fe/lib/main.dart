import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/models/cost.dart';
import 'data/repositories/cost_repository.dart';
import 'data/repositories/user_repository.dart';
import 'features/cost_form/cost_form_notifier.dart';
import 'features/cost_form/cost_form_screen.dart';
import 'features/home/home_notifier.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final client = ApiClient(baseUrl: AppConfig.baseUrl);
  final costRepo = CostRepository(client);
  final homeNotifier = HomeNotifier(
    userRepo: UserRepository(client),
    costRepo: costRepo,
    prefs: prefs,
  );

  runApp(MimmisApp(homeNotifier: homeNotifier, costRepo: costRepo));
}

class MimmisApp extends StatelessWidget {
  const MimmisApp({
    super.key,
    required this.homeNotifier,
    required this.costRepo,
  });

  final HomeNotifier homeNotifier;
  final CostRepository costRepo;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => HomeScreen(notifier: homeNotifier),
        ),
        GoRoute(
          path: '/cost-form',
          builder: (_, state) {
            final initialCost = state.extra as Cost?;
            return CostFormScreen(
              notifier: CostFormNotifier(
                costRepo: costRepo,
                selectedUser: homeNotifier.selectedUser,
                selectedDate: homeNotifier.selectedDate,
                initialCost: initialCost,
              ),
            );
          },
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
