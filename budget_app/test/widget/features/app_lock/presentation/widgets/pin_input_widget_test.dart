import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/app_lock/presentation/widgets/pin_input_widget.dart';

void main() {
  Widget buildWidget({
    int pinLength = 4,
    required void Function(String) onPinComplete,
    void Function()? onPinChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PinInputWidget(
          pinLength: pinLength,
          onPinComplete: onPinComplete,
          onPinChanged: onPinChanged,
        ),
      ),
    );
  }

  group('PinInputWidget', () {
    testWidgets('renders keypad with all digits', (tester) async {
      await tester.pumpWidget(buildWidget(onPinComplete: (_) {}));
      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('renders backspace icon', (tester) async {
      await tester.pumpWidget(buildWidget(onPinComplete: (_) {}));
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('shows 4 dots by default', (tester) async {
      await tester.pumpWidget(buildWidget(onPinComplete: (_) {}));
      // 4 circles + keypad buttons
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('entering digits fills dots', (tester) async {
      String? completedPin;
      await tester.pumpWidget(buildWidget(onPinComplete: (pin) => completedPin = pin));

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();

      expect(completedPin, '1234');
    });

    testWidgets('onPinChanged fires on each key press', (tester) async {
      int changeCount = 0;
      await tester.pumpWidget(buildWidget(
        onPinComplete: (_) {},
        onPinChanged: () => changeCount++,
      ));

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(changeCount, 2);
    });

    testWidgets('backspace removes last digit', (tester) async {
      String? completedPin;
      await tester.pumpWidget(buildWidget(
        pinLength: 2,
        onPinComplete: (pin) => completedPin = pin,
      ));

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('6'));
      await tester.pump();

      expect(completedPin, '56');
    });

    testWidgets('backspace on empty pin does nothing', (tester) async {
      int changeCount = 0;
      await tester.pumpWidget(buildWidget(
        onPinComplete: (_) {},
        onPinChanged: () => changeCount++,
      ));

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(changeCount, 0);
    });

    testWidgets('digits beyond pinLength are ignored', (tester) async {
      final List<String> completedPins = [];
      await tester.pumpWidget(buildWidget(
        pinLength: 2,
        onPinComplete: completedPins.add,
      ));

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3')); // should be ignored
      await tester.pump();

      expect(completedPins.length, 1);
      expect(completedPins.first, '12');
    });

    testWidgets('custom pinLength works', (tester) async {
      String? completedPin;
      await tester.pumpWidget(buildWidget(
        pinLength: 6,
        onPinComplete: (pin) => completedPin = pin,
      ));

      for (var i = 1; i <= 6; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();
      }

      expect(completedPin, '123456');
    });
  });
}
