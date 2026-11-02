import 'package:budget_app/core/localization/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Platform-forcing test harness for the adaptive helper kit
/// (feature 040-material-cupertino-ui).
///
/// The kit branches on `Theme.of(context).platform`, so [pump] always builds a
/// [MaterialApp] whose theme carries the forced [TargetPlatform]. Framework
/// level behaviors are driven by `debugDefaultTargetPlatformOverride` through
/// [platformVariant], which restores the override inside the test body's
/// variant zone. That ordering is REQUIRED: `testWidgets` verifies
/// `debugAssertAllFoundationVarsUnset` before `addTearDown` callbacks run
/// (flutter_test binding `_runTestBody`), so plain `addTearDown` resets fail the
/// invariant check. The variant teardown is the leak-proof reset
/// (research.md Decision 8 leak risk); the group-level `tearDown` assertion in
/// `adaptive_test_harness_test.dart` proves the override never leaks.
class AdaptiveTestHarness {
  const AdaptiveTestHarness._();

  /// Whether [platform] takes the Cupertino branch per
  /// `contracts/adaptive_helpers_contract.md` (Apple platforms = iOS + macOS).
  static bool isCupertino(TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  /// Leak-proof driver for `debugDefaultTargetPlatformOverride`.
  ///
  /// Usage:
  /// ```dart
  /// testWidgets('...', (tester) async { ... },
  ///   variant: AdaptiveTestHarness.platformVariant(TargetPlatform.iOS));
  /// ```
  static TestVariant<Object?> platformVariant(TargetPlatform platform) =>
      TargetPlatformVariant.only(platform);

  /// Pumps [child] under a [MaterialApp] whose theme carries [platform].
  ///
  /// Combine with [platformVariant] so framework internals agree with the
  /// forced theme platform. Must be called from inside `testWidgets`.
  static Future<void> pump(
    WidgetTester tester, {
    required Widget child,
    required TargetPlatform platform,
    ThemeData? theme,
  }) async {
    final ThemeData effectiveTheme = (theme ?? ThemeData(platform: platform))
        .copyWith(platform: platform);
    await tester.pumpWidget(
      MaterialApp(
        theme: effectiveTheme,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en')],
        home: child,
      ),
    );
    // Advance past the 200ms MaterialApp theme animation so sequential pump()
    // calls in one test do not observe ThemeData.lerp mid-animation (platform
    // switches at t < 0.5). A fixed pump is used instead of pumpAndSettle so
    // perpetually animating children (progress spinners) cannot hang the pump.
    await tester.pump(const Duration(milliseconds: 250));
  }
}
