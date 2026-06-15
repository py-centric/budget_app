import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/di/app_module.dart';
import 'core/theme/app_theme.dart';
import 'features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'features/app_lock/presentation/bloc/app_lock_event.dart';
import 'features/app_lock/presentation/bloc/app_lock_state.dart';
import 'features/app_lock/presentation/pages/lock_screen_page.dart';
import 'features/budget/presentation/pages/home_page.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  final appModule = AppModule();
  await appModule.init();

  runApp(
    MultiRepositoryProvider(
      providers: appModule.repositoryProviders,
      child: BudgetApp(appModule: appModule),
    ),
  );
}

class BudgetApp extends StatelessWidget {
  final AppModule appModule;

  const BudgetApp({super.key, required this.appModule});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: appModule.blocProviders,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          ThemeMode mode;
          switch (state.settings.themeMode) {
            case 'light':
              mode = ThemeMode.light;
              break;
            case 'dark':
              mode = ThemeMode.dark;
              break;
            default:
              mode = ThemeMode.system;
          }

          return BlocBuilder<AppLockBloc, AppLockState>(
            builder: (context, appLockState) {
              // Show lock screen ONLY if lock is actually enabled and user hasn't authenticated yet
              // Don't show lock screen if:
              // - Lock is not enabled
              // - Status is loaded (initial load complete, lock not enabled)
              // - Status is initial (still loading)
              // - Status is authenticated
              final shouldShowLock =
                  appLockState.settings.isEnabled &&
                  appLockState.status != AppLockStatus.authenticated &&
                  appLockState.status != AppLockStatus.loaded &&
                  appLockState.status != AppLockStatus.initial &&
                  appLockState.status != AppLockStatus.loading;

              if (shouldShowLock) {
                return MaterialApp(
                  title: 'Budget App',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: mode,
                  home: LockScreenPage(
                    onUnlocked: () {
                      context.read<AppLockBloc>().add(AppLockLoadSettings());
                    },
                  ),
                );
              }

              return MaterialApp(
                title: 'Budget App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: mode,
                home: const HomePage(),
              );
            },
          );
        },
      ),
    );
  }
}
