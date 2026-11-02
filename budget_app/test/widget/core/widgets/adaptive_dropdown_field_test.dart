import 'package:budget_app/core/widgets/adaptive_dropdown_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/adaptive_test_harness.dart';

void main() {
  final List<AdaptiveDropdownItem<int>> items = <AdaptiveDropdownItem<int>>[
    const AdaptiveDropdownItem<int>(
      value: 1,
      label: Text('One'),
      semanticsLabel: 'One',
    ),
    const AdaptiveDropdownItem<int>(
      value: 2,
      label: Text('Two'),
      semanticsLabel: 'Two',
    ),
    const AdaptiveDropdownItem<int>(
      value: 3,
      label: Text('Three'),
      semanticsLabel: 'Three',
    ),
  ];

  Widget buildField({
    int? value = 1,
    ValueChanged<int?>? onChanged,
  }) {
    return Material(
      child: Center(
        child: AdaptiveDropdownField<int>(
          items: items,
          value: value,
          onChanged: onChanged ?? (int? _) {},
          hint: const Text('Pick'),
        ),
      ),
    );
  }

  group('AdaptiveDropdownField - Android branch', () {
    testWidgets('renders a Material DropdownButtonFormField', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: buildField(),
      );

      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsNothing);
    });

    testWidgets('selecting fires onChanged synchronously', (tester) async {
      int? reported;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: buildField(onChanged: (int? value) => reported = value),
      );

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Two').last);
      await tester.pumpAndSettle();

      expect(reported, 2);
    });

    testWidgets('null value renders the hint without crashing',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: buildField(value: null),
      );

      expect(find.text('Pick'), findsOneWidget);
    });
  });

  group('AdaptiveDropdownField - iOS branch', () {
    testWidgets(
        'tapping the field opens a CupertinoPicker wheel with Done/Cancel',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildField(),
      );

      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPicker), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<int>), findsNothing);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets(
        'scroller starts at the selected value index (FixedExtentScrollController)',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildField(value: 3),
      );

      await tester.tap(find.text('Three'));
      await tester.pumpAndSettle();

      final CupertinoPicker picker = tester.widget(find.byType(CupertinoPicker));
      expect(picker.itemExtent, 36);
      final FixedExtentScrollController? controller =
          picker.scrollController;
      expect(controller, isNotNull);
      expect(controller!.initialItem, 2);
    });

    testWidgets('Cancel closes without calling onChanged', (tester) async {
      int? reported;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildField(onChanged: (int? value) => reported = value),
      );

      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(reported, isNull);
    });

    testWidgets('Done calls onChanged with the picked value', (tester) async {
      int? reported;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildField(onChanged: (int? value) => reported = value),
      );

      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CupertinoPicker), const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(reported, isNull,
          reason: 'dragging must not commit; only Done does');

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(reported, isNotNull);
      expect(reported, isNot(1));
    });

    testWidgets('null value renders the hint and the field stays tappable',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildField(value: null),
      );

      expect(find.text('Pick'), findsOneWidget);
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoPicker), findsOneWidget);
    });

    testWidgets('the field trigger provides a >= 48dp touch row',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildField(),
      );

      expect(
        tester.getSize(find.byType(AdaptiveDropdownField<int>)).height,
        greaterThanOrEqualTo(48.0),
      );
    });
  });

  group('AdaptiveDropdownField - macOS representative', () {
    testWidgets('macOS keeps the desktop Material dropdown', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.macOS,
        child: buildField(),
      );

      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsNothing);
    });
  });
}
