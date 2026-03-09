import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/models/cost.dart';
import 'data/models/user.dart';
import 'data/repositories/cost_repository.dart';
import 'data/repositories/user_repository.dart';
import 'features/cost_form/cost_form_notifier.dart';
import 'features/cost_form/cost_form_screen.dart';
import 'features/home/home_notifier.dart';
import 'features/home/home_screen.dart';
import 'features/user_manage/user_form_notifier.dart';
import 'features/user_manage/user_form_screen.dart';
import 'features/user_manage/user_manage_notifier.dart';
import 'features/user_manage/user_manage_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final client = ApiClient(baseUrl: AppConfig.baseUrl);
  final userRepo = UserRepository(client);
  final costRepo = CostRepository(client);
  final homeNotifier = HomeNotifier(
    userRepo: userRepo,
    costRepo: costRepo,
    prefs: prefs,
  );
  final userManageNotifier = UserManageNotifier(userRepo: userRepo);

  runApp(MimmisApp(
    homeNotifier: homeNotifier,
    costRepo: costRepo,
    userRepo: userRepo,
    userManageNotifier: userManageNotifier,
  ));
}

class MimmisApp extends StatelessWidget {
  const MimmisApp({
    super.key,
    required this.homeNotifier,
    required this.costRepo,
    required this.userRepo,
    required this.userManageNotifier,
  });

  final HomeNotifier homeNotifier;
  final CostRepository costRepo;
  final UserRepository userRepo;
  final UserManageNotifier userManageNotifier;

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
        GoRoute(
          path: '/user-manager',
          builder: (_, _) => UserManageScreen(
            notifier: userManageNotifier,
          ),
        ),
        GoRoute(
          path: '/user-form',
          builder: (_, state) {
            final initialUser = state.extra as User?;
            return UserFormScreen(
              notifier: UserFormNotifier(
                userRepo: userRepo,
                initialUser: initialUser,
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

