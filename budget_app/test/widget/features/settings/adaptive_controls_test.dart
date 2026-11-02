import 'dart:async';
import 'dart:io';

import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_state.dart';
import 'package:budget_app/features/settings/presentation/widgets/settings_sections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/adaptive_test_harness.dart';

class MockAppLockBloc extends Mock implements AppLockBloc {}

/// US1 call-site tests (T015): the real settings switch surface must render
/// platform-adaptive controls (Cupertino on iOS/macOS, Material on Android)
/// with the Android rendering unchanged from the pre-migration baseline.
void main() {
  late MockAppLockBloc mockAppLockBloc;

  setUp(() {
    mockAppLockBloc = MockAppLockBloc();
    when(() => mockAppLockBloc.state).thenReturn(const AppLockState());
    when(
      () => mockAppLockBloc.stream,
    ).thenAnswer((_) => const Stream<AppLockState>.empty());
  });

  Widget switchSurface() {
    return Scaffold(
      body: BlocProvider<AppLockBloc>.value(
        value: mockAppLockBloc,
        child: const SingleChildScrollView(child: AppLockSettingsSection()),
      ),
    );
  }

  group('settings switch call site - Android branch (zero-regression)', () {
    testWidgets('renders the Material switch with no Cupertino chrome',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: switchSurface(),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNothing);
    });

    testWidgets('keeps its accessibility semantics', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: switchSurface(),
      );

      expect(find.text('App Lock'), findsOneWidget);
      expect(tester.getSemantics(find.byType(Switch)), isNotNull);
    });
  });

  group('settings switch call site - iOS branch', () {
    testWidgets('renders with Cupertino styling (golden diverges from Android)',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: switchSurface(),
      );
      await expectLater(
        find.byType(AppLockSettingsSection),
        matchesGoldenFile('../../../goldens/settings_switch_android_light.png'),
      );

      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: switchSurface(),
      );
      await expectLater(
        find.byType(AppLockSettingsSection),
        matchesGoldenFile('../../../goldens/settings_switch_ios_light.png'),
      );

      // Switch.adaptive adapts the switch config per platform (Cupertino
      // track/thumb rendering on Apple platforms in this SDK), so the iOS
      // rendering must diverge from the Android rendering at the pixel level.
      final List<int> androidBytes = File(
        'test/goldens/settings_switch_android_light.png',
      ).readAsBytesSync();
      final List<int> iosBytes = File(
        'test/goldens/settings_switch_ios_light.png',
      ).readAsBytesSync();
      expect(
        iosBytes,
        isNot(equals(androidBytes)),
        reason: 'the Cupertino branch must render differently from Android',
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('settings switch call site - macOS representative', () {
    testWidgets('macOS renders with Cupertino styling (golden diverges from Android)',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: switchSurface(),
      );
      await expectLater(
        find.byType(AppLockSettingsSection),
        matchesGoldenFile('../../../goldens/settings_switch_android_light.png'),
      );

      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.macOS,
        child: switchSurface(),
      );
      await expectLater(
        find.byType(AppLockSettingsSection),
        matchesGoldenFile('../../../goldens/settings_switch_macos_light.png'),
      );

      final List<int> androidBytes = File(
        'test/goldens/settings_switch_android_light.png',
      ).readAsBytesSync();
      final List<int> macOSBytes = File(
        'test/goldens/settings_switch_macos_light.png',
      ).readAsBytesSync();
      expect(macOSBytes, isNot(equals(androidBytes)));
      expect(tester.takeException(), isNull);
    });
  });

  group('loading states (adaptive constructor contract)', () {
    // The 33 CircularProgressIndicator call sites migrate to the framework's
    // .adaptive constructor (T018); this probe pins its branch behavior.
    testWidgets('iOS renders CupertinoActivityIndicator', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('Android renders the Material spinner', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });
  });
}
