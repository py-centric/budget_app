import 'package:budget_app/core/widgets/adaptive_date_picker.dart';
import 'package:budget_app/core/widgets/adaptive_dropdown_field.dart';
import 'package:budget_app/core/widgets/adaptive_modal_sheet.dart';
import 'package:budget_app/core/widgets/adaptive_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/adaptive_test_harness.dart';

/// Golden parity harness for the adaptive helper kit (T013).
///
/// Captures every helper under android/ios x light/dark using the default
/// `flutter_test` fonts so Linux CI rendering is deterministic. Regenerate
/// with: `flutter test test/widget/core/widgets/adaptive_kit_goldens_test.dart --update-goldens`.
void main() {
  Future<void> capture(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../goldens/$name.png'),
    );
  }

  const List<TargetPlatform> platforms = <TargetPlatform>[
    TargetPlatform.android,
    TargetPlatform.iOS,
  ];
  const List<String> modes = <String>['light', 'dark'];

  final List<AdaptiveDropdownItem<int>> dropdownItems =
      <AdaptiveDropdownItem<int>>[
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

  for (final TargetPlatform platform in platforms) {
    final String platformName =
        platform == TargetPlatform.android ? 'android' : 'ios';
    for (final String mode in modes) {
      final Brightness brightness =
          mode == 'light' ? Brightness.light : Brightness.dark;
      final ThemeData theme = ThemeData(
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: brightness,
        ),
        platform: platform,
      );

      testWidgets('golden: segmented $platformName $mode', (tester) async {
        await AdaptiveTestHarness.pump(
          tester,
          platform: platform,
          theme: theme,
          child: const Scaffold(
            body: Center(
              child: AdaptiveSegmentedControl<int>(
                segments: <AdaptiveSegment<int>>[
                  AdaptiveSegment<int>(
                    value: 0,
                    label: Text('Day'),
                    semanticsLabel: 'Day view',
                  ),
                  AdaptiveSegment<int>(
                    value: 1,
                    label: Text('Week'),
                    semanticsLabel: 'Week view',
                  ),
                  AdaptiveSegment<int>(
                    value: 2,
                    label: Text('Month'),
                    semanticsLabel: 'Month view',
                  ),
                ],
                selected: 1,
                onChanged: _ignoreInt,
              ),
            ),
          ),
        );
        await capture(tester, 'kit_segmented_${platformName}_$mode');
      });

      testWidgets('golden: dropdown $platformName $mode', (tester) async {
        await AdaptiveTestHarness.pump(
          tester,
          platform: platform,
          theme: theme,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 280,
                child: AdaptiveDropdownField<int>(
                  items: dropdownItems,
                  value: 2,
                  onChanged: _ignoreIntNullable,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Pick'),
                ),
              ),
            ),
          ),
        );
        await capture(tester, 'kit_dropdown_${platformName}_$mode');
      });

      testWidgets('golden: modal sheet $platformName $mode', (tester) async {
        await AdaptiveTestHarness.pump(
          tester,
          platform: platform,
          theme: theme,
          child: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    showAdaptiveModalSheet<void>(
                      context: context,
                      builder: (_) => const SizedBox(
                        height: 120,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 60,
                              child: Center(child: Text('First action')),
                            ),
                            SizedBox(
                              height: 60,
                              child: Center(child: Text('Second action')),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await capture(tester, 'kit_sheet_${platformName}_$mode');
      });

      testWidgets('golden: date picker $platformName $mode', (tester) async {
        await AdaptiveTestHarness.pump(
          tester,
          platform: platform,
          theme: theme,
          child: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    showAdaptiveDatePicker(
                      context: context,
                      initialDate: DateTime(2026, 11, 2),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                  },
                  child: const Text('Pick date'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Pick date'));
        await tester.pumpAndSettle();
        await capture(tester, 'kit_date_picker_${platformName}_$mode');
      });
    }
  }
}

void _ignoreInt(int? _) {}

void _ignoreIntNullable(int? _) {}
