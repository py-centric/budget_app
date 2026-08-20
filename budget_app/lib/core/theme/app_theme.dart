import 'package:flutter/material.dart';
import 'app_spacing.dart';
import 'app_theme_extensions.dart';
import 'domain_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme(Color seedColor, DomainColors domainColors) {
    return AppThemeExtensions.extend(
      _baseTheme(
        ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      domainColors,
    );
  }

  static ThemeData darkTheme(Color seedColor, DomainColors domainColors) {
    return AppThemeExtensions.extend(
      _baseTheme(
        ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      domainColors,
    );
  }

  static ThemeData oledDarkTheme(Color seedColor, DomainColors domainColors) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF000000),
      onSurface: const Color(0xFFE0E0E0),
      surfaceContainerLowest: const Color(0xFF000000),
      surfaceContainerLow: const Color(0xFF0A0A0A),
      surfaceContainer: const Color(0xFF111111),
      surfaceContainerHigh: const Color(0xFF1A1A1A),
      surfaceContainerHighest: const Color(0xFF222222),
      surfaceBright: const Color(0xFF2A2A2A),
      surfaceDim: const Color(0xFF050505),
    );

    return AppThemeExtensions.extend(
      ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF000000),
          surfaceTintColor: Color(0xFF000000),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
          ),
          filled: true,
          fillColor: Color(0xFF111111),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF0A0A0A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(AppRadius.lg),
              bottomRight: Radius.circular(AppRadius.lg),
            ),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF111111),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF111111),
        ),
        navigationDrawerTheme: const NavigationDrawerThemeData(
          backgroundColor: Color(0xFF0A0A0A),
        ),
      ),
      domainColors,
    );
  }

  static ThemeData highContrastTheme(Color seedColor, DomainColors domainColors) {
    const highContrastColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF00FFFF),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF004D4D),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFFFFFF00),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFF4D4D00),
      onSecondaryContainer: Color(0xFFFFFFFF),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFF0F0F0),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF000000),
      surfaceContainer: Color(0xFF0A0A0A),
      surfaceContainerHigh: Color(0xFF141414),
      surfaceContainerHighest: Color(0xFF1E1E1E),
      surfaceBright: Color(0xFF282828),
      surfaceDim: Color(0xFF000000),
      error: Color(0xFFFF3333),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFF5C0000),
      onErrorContainer: Color(0xFFFFFFFF),
      outline: Color(0xFFFFFFFF),
      outlineVariant: Color(0xFFE0E0E0),
    );

    const highContrastDomainColors = DomainColors(
      incomeColor: Color(0xFF00FF66),
      expenseColor: Color(0xFFFF3333),
    );

    return AppThemeExtensions.extend(
      ThemeData(
        useMaterial3: true,
        colorScheme: highContrastColorScheme,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF000000),
          foregroundColor: Color(0xFFFFFFFF),
          surfaceTintColor: Color(0xFF000000),
          shape: Border(bottom: BorderSide(color: Color(0xFFFFFFFF), width: 1.5)),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFF000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
            side: BorderSide(color: Color(0xFFFFFFFF), width: 1.5),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            borderSide: BorderSide(color: Color(0xFF00FFFF), width: 2.5),
          ),
          filled: true,
          fillColor: Color(0xFF000000),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFFF),
            foregroundColor: const Color(0xFF000000),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
              side: BorderSide(color: Color(0xFFFFFFFF), width: 1.5),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00FFFF),
            side: const BorderSide(color: Color(0xFF00FFFF), width: 1.5),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFFFFFFF),
          thickness: 1.5,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF000000),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFFFFFFF), width: 1.5),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(AppRadius.lg),
              bottomRight: Radius.circular(AppRadius.lg),
            ),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
            side: BorderSide(color: Color(0xFFFFFFFF), width: 2.0),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            side: BorderSide(color: Color(0xFFFFFFFF), width: 1.5),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Color(0xFFFFFFFF),
          iconColor: Color(0xFF00FFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
          ),
        ),
      ),
      highContrastDomainColors,
    );
  }


  static ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}
