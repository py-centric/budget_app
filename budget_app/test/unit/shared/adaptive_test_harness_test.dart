import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/adaptive_test_harness.dart';

void main() {
  group('AdaptiveTestHarness', () {
    tearDown(() {
      expect(
        debugDefaultTargetPlatformOverride,
        isNull,
        reason:
            'the platform override must never leak past a test (research Decision 8)',
      );
    });

    testWidgets(
      'platformVariant drives the override and restores it in-zone',
      (tester) async {
        await AdaptiveTestHarness.pump(
          tester,
          platform: TargetPlatform.iOS,
          child: const SizedBox(key: Key('probe')),
        );

        final BuildContext context = tester.element(find.byKey(const Key('probe')));
        expect(Theme.of(context).platform, TargetPlatform.iOS);
        expect(debugDefaultTargetPlatformOverride, TargetPlatform.iOS);
      },
      variant: AdaptiveTestHarness.platformVariant(TargetPlatform.iOS),
    );

    testWidgets(
      'override is null again at the start of the next test',
      (tester) async {
        expect(debugDefaultTargetPlatformOverride, isNull);
      },
    );

    testWidgets(
      'pump forces the theme platform for all three branch platforms',
      (tester) async {
        for (final TargetPlatform platform in <TargetPlatform>[
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ]) {
          await AdaptiveTestHarness.pump(
            tester,
            platform: platform,
            child: const SizedBox(key: Key('probe')),
          );
          final BuildContext context = tester.element(find.byKey(const Key('probe')));
          expect(Theme.of(context).platform, platform);
          expect(
            AdaptiveTestHarness.isCupertino(platform),
            platform != TargetPlatform.android,
          );
        }
      },
    );
  });
}
