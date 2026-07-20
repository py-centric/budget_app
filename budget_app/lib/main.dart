import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/di/app_module.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/domain_colors.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/splash/presentation/pages/splash_page.dart';

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
          final seedColor = Color(state.settings.seedColor);
          final domainColors = DomainColors(
            incomeColor: Color(state.settings.incomeColor),
            expenseColor: Color(state.settings.expenseColor),
          );

          ThemeMode mode;
          ThemeData? darkTheme;
          switch (state.settings.themeMode) {
            case 'light':
              mode = ThemeMode.light;
              break;
            case 'dark':
              mode = ThemeMode.dark;
              break;
            case 'oled':
              mode = ThemeMode.dark;
              darkTheme = AppTheme.oledDarkTheme(seedColor, domainColors);
              break;
            default:
              mode = ThemeMode.system;
          }

          return MaterialApp(
            title: 'Budget App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(seedColor, domainColors),
            darkTheme: darkTheme ?? AppTheme.darkTheme(seedColor, domainColors),
            themeMode: mode,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
