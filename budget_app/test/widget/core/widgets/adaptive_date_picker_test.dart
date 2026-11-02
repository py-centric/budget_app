import 'package:budget_app/core/widgets/adaptive_date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/adaptive_test_harness.dart';

void main() {
  final DateTime initialDate = DateTime(2026, 11, 2);
  final DateTime firstDate = DateTime(2020);
  final DateTime lastDate = DateTime(2030);
  const TimeOfDay initialTime = TimeOfDay(hour: 14, minute: 30);

  Widget launcher(
    void Function(BuildContext context) onOpenDate,
    void Function(BuildContext context) onOpenTime,
  ) {
    return Builder(
      builder: (BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => onOpenDate(context),
            child: const Text('Pick date'),
          ),
          ElevatedButton(
            onPressed: () => onOpenTime(context),
            child: const Text('Pick time'),
          ),
        ],
      ),
    );
  }

  group('showAdaptiveDatePicker - Android branch', () {
    testWidgets('opens the Material DatePickerDialog and resolves on OK',
        (tester) async {
      late Future<DateTime?> future;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: launcher(
          (BuildContext context) {
            future = showAdaptiveDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
          },
          (_) {},
        ),
      );

      await tester.tap(find.text('Pick date'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(await future, initialDate);
    });

    testWidgets('resolves null on Cancel', (tester) async {
      late Future<DateTime?> future;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: launcher(
          (BuildContext context) {
            future = showAdaptiveDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
          },
          (_) {},
        ),
      );

      await tester.tap(find.text('Pick date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });
  });

  group('showAdaptiveDatePicker - iOS branch', () {
    testWidgets(
        'hosts a CupertinoDatePicker in a popup with a Done/Cancel bar',
        (tester) async {
      late Future<DateTime?> future;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher(
          (BuildContext context) {
            future = showAdaptiveDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
          },
          (_) {},
        ),
      );

      await tester.tap(find.text('Pick date'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(future, isNotNull);
    });

    testWidgets(
        'maps initial/first/last dates and truncates the initial value to day',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher(
          (BuildContext context) {
            showAdaptiveDatePicker(
              context: context,
              initialDate: DateTime(2026, 11, 2, 15, 45),
              firstDate: firstDate,
              lastDate: lastDate,
            );
          },
          (_) {},
        ),
      );

      await tester.tap(find.text('Pick date'));
      await tester.pumpAndSettle();

      final CupertinoDatePicker picker = tester.widget(
        find.byType(CupertinoDatePicker),
      );
      expect(picker.mode, CupertinoDatePickerMode.date);
      expect(picker.initialDateTime, DateTime(2026, 11, 2));
      expect(picker.minimumDate, firstDate);
      expect(picker.maximumDate, lastDate);
    });

    testWidgets(
        'wheel changes do not resolve before Done; Done returns the last value',
        (tester) async {
      bool completed = false;
      DateTime? result;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher(
          (BuildContext context) {
            showAdaptiveDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            ).then((DateTime? value) {
              completed = true;
              result = value;
            });
          },
          (_) {},
        ),
      );

      await tester.tap(find.text('Pick date'));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(CupertinoDatePicker),
        const Offset(0, -72),
      );
      await tester.pumpAndSettle();
      expect(completed, isFalse,
          reason: 'the wheel must not resolve the Future while dragging');

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(result, isNotNull);
    });

    testWidgets('Cancel resolves null', (tester) async {
      late Future<DateTime?> future;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher(
          (BuildContext context) {
            future = showAdaptiveDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
          },
          (_) {},
        ),
      );

      await tester.tap(find.text('Pick date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });
  });

  group('showAdaptiveTimePicker', () {
    testWidgets('Android branch opens the Material TimePickerDialog',
        (tester) async {
      late Future<TimeOfDay?> future;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: launcher(
          (_) {},
          (BuildContext context) {
            future = showAdaptiveTimePicker(
              context: context,
              initialTime: initialTime,
            );
          },
        ),
      );

      await tester.tap(find.text('Pick time'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final TimeOfDay? result = await future;
      expect(result?.hour, 14);
      expect(result?.minute, 30);
    });

    testWidgets('iOS branch hosts CupertinoDatePicker in time mode with Done',
        (tester) async {
      bool completed = false;
      TimeOfDay? result;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher(
          (_) {},
          (BuildContext context) {
            showAdaptiveTimePicker(
              context: context,
              initialTime: initialTime,
            ).then((TimeOfDay? value) {
              completed = true;
              result = value;
            });
          },
        ),
      );

      await tester.tap(find.text('Pick time'));
      await tester.pumpAndSettle();

      final CupertinoDatePicker picker = tester.widget(
        find.byType(CupertinoDatePicker),
      );
      expect(picker.mode, CupertinoDatePickerMode.time);
      expect(find.text('Done'), findsOneWidget);
      expect(completed, isFalse);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(result?.hour, 14);
      expect(result?.minute, 30);
    });

    testWidgets('iOS Cancel resolves null', (tester) async {
      late Future<TimeOfDay?> future;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: launcher(
          (_) {},
          (BuildContext context) {
            future = showAdaptiveTimePicker(
              context: context,
              initialTime: initialTime,
            );
          },
        ),
      );

      await tester.tap(find.text('Pick time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });
  });

  group('showAdaptiveDatePicker - macOS representative', () {
    testWidgets('macOS takes the Cupertino branch', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.macOS,
        child: launcher(
          (BuildContext context) {
            showAdaptiveDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
          },
          (_) {},
        ),
      );

      await tester.tap(find.text('Pick date'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoDatePicker), findsOneWidget);
    });
  });
}
