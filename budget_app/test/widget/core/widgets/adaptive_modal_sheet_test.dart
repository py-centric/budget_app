import 'package:budget_app/core/widgets/adaptive_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/adaptive_test_harness.dart';

void main() {
  Widget launcher(void Function(BuildContext context) onOpen) {
    return Builder(
      builder: (BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: () => onOpen(context),
          child: const Text('Open'),
        ),
      ),
    );
  }

  group('showAdaptiveModalSheet - Android branch', () {
    testWidgets('opens a Material bottom sheet', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: launcher((BuildContext context) {
          showAdaptiveModalSheet<void>(
            context: context,
            builder: (_) => const SizedBox(height: 48, child: Text('Sheet content')),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(CupertinoPopupSurface), findsNothing);
      expect(find.text('Sheet content'), findsOneWidget);
    });

    testWidgets('barrier dismiss resolves null', (tester) async {
      late Future<String?> sheetFuture;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: launcher((BuildContext context) {
          sheetFuture = showAdaptiveModalSheet<String>(
            context: context,
            builder: (_) => const SizedBox(height: 48, child: Text('Sheet content')),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(await sheetFuture, isNull);
    });

    testWidgets('action resolves the content value', (tester) async {
      late Future<String?> sheetFuture;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: launcher((BuildContext context) {
          sheetFuture = showAdaptiveModalSheet<String>(
            context: context,
            builder: (BuildContext sheetContext) => SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop('chosen'),
                child: const Text('Choose'),
              ),
            ),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();

      expect(await sheetFuture, 'chosen');
    });

    testWidgets('48dp rows render without overflow at max text scale',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: launcher((BuildContext context) {
            showAdaptiveModalSheet<void>(
              context: context,
              builder: (_) => const SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text('Row label'), Text('Row value')],
                ),
              ),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('showAdaptiveModalSheet - iOS branch', () {
    testWidgets('opens a Cupertino popup surface, not a Material sheet',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher((BuildContext context) {
          showAdaptiveModalSheet<void>(
            context: context,
            builder: (_) => const SizedBox(height: 48, child: Text('Sheet content')),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('barrier tap dismisses and resolves null', (tester) async {
      late Future<String?> sheetFuture;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher((BuildContext context) {
          sheetFuture = showAdaptiveModalSheet<String>(
            context: context,
            builder: (_) => const SizedBox(height: 48, child: Text('Sheet content')),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(await sheetFuture, isNull);
    });

    testWidgets('action resolves the content value', (tester) async {
      late Future<String?> sheetFuture;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher((BuildContext context) {
          sheetFuture = showAdaptiveModalSheet<String>(
            context: context,
            builder: (BuildContext sheetContext) => SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop('chosen'),
                child: const Text('Choose'),
              ),
            ),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();

      expect(await sheetFuture, 'chosen');
    });
  });

  group('showAdaptiveModalSheet - chrome options', () {
    testWidgets('l10nTitleKey renders the header and backgroundColor applies',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher((BuildContext context) {
          showAdaptiveModalSheet<void>(
            context: context,
            l10nTitleKey: 'cancel',
            backgroundColor: const Color(0xFF101820),
            builder: (_) => const SizedBox(height: 48, child: Text('Sheet content')),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget,
          reason: 'the l10n header label must resolve via AppLocalizations');
      expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Material branch applies backgroundColor and the header',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: launcher((BuildContext context) {
          showAdaptiveModalSheet<void>(
            context: context,
            l10nTitleKey: 'cancel',
            backgroundColor: const Color(0xFF101820),
            builder: (_) => const SizedBox(height: 48, child: Text('Sheet content')),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('showAdaptiveModalSheet - macOS representative', () {
    testWidgets('macOS takes the Cupertino branch', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.macOS,
        child: launcher((BuildContext context) {
          showAdaptiveModalSheet<void>(
            context: context,
            builder: (_) => const SizedBox(height: 48, child: Text('Sheet content')),
          );
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });
}
