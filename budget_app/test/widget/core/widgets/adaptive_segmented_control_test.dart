import 'package:budget_app/core/widgets/adaptive_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/adaptive_test_harness.dart';

void main() {
  const List<AdaptiveSegment<int>> segments = <AdaptiveSegment<int>>[
    AdaptiveSegment<int>(
      value: 0,
      label: Text('A'),
      semanticsLabel: 'Option A',
    ),
    AdaptiveSegment<int>(
      value: 1,
      label: Text('B'),
      semanticsLabel: 'Option B',
    ),
  ];

  Widget buildControl({
    int selected = 0,
    ValueChanged<int?>? onChanged,
  }) {
    return Center(
      child: AdaptiveSegmentedControl<int>(
        segments: segments,
        selected: selected,
        onChanged: onChanged ?? (int? _) {},
      ),
    );
  }

  Finder semanticsWithLabel(String label) {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is Semantics && widget.properties.label == label,
    );
  }

  group('AdaptiveSegmentedControl - Android branch', () {
    testWidgets('renders a Material SegmentedButton', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: buildControl(),
      );

      expect(find.byType(SegmentedButton<int>), findsOneWidget);
      expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsNothing);
    });

    testWidgets('single-select fires onChanged with the new value',
        (tester) async {
      int? reported;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: buildControl(onChanged: (int? value) => reported = value),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(reported, 1);
    });

    testWidgets('semantics labels are retained', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: buildControl(),
      );

      expect(semanticsWithLabel('Option A'), findsOneWidget);
      expect(semanticsWithLabel('Option B'), findsOneWidget);
    });
  });

  group('AdaptiveSegmentedControl - iOS branch', () {
    testWidgets('renders a CupertinoSlidingSegmentedControl', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildControl(),
      );

      expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsOneWidget);
      expect(find.byType(SegmentedButton<int>), findsNothing);
    });

    testWidgets('colors derive from the ambient ColorScheme, not hard-coded',
        (tester) async {
      final ThemeData theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        platform: TargetPlatform.iOS,
      );
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        theme: theme,
        child: buildControl(),
      );

      final CupertinoSlidingSegmentedControl<int> widget = tester.widget(
        find.byType(CupertinoSlidingSegmentedControl<int>),
      );
      expect(widget.thumbColor, theme.colorScheme.primary);
      expect(widget.backgroundColor, theme.colorScheme.surfaceContainerLow);
    });

    testWidgets('tap fires onChanged with the new value', (tester) async {
      int? reported;
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildControl(onChanged: (int? value) => reported = value),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(reported, 1);
    });

    testWidgets('semantics labels are retained', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: buildControl(),
      );

      expect(semanticsWithLabel('Option A'), findsOneWidget);
      expect(semanticsWithLabel('Option B'), findsOneWidget);
    });

    testWidgets('no overflow at max text scale', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
          child: buildControl(),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('AdaptiveSegmentedControl - macOS representative', () {
    testWidgets('macOS takes the Cupertino branch', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.macOS,
        child: buildControl(),
      );

      expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsOneWidget);
    });
  });
}
