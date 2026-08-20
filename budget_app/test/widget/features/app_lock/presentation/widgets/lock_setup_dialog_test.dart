import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/app_lock/presentation/widgets/lock_setup_dialog.dart';
import 'package:budget_app/features/app_lock/domain/entities/app_lock_settings.dart';
import 'package:budget_app/features/app_lock/presentation/widgets/pin_input_widget.dart';

void main() {
  Widget buildDialog({
    bool isBiometricAvailable = false,
    required void Function(AuthMethod, String?) onComplete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => LockSetupDialog(
                isBiometricAvailable: isBiometricAvailable,
                onComplete: onComplete,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('LockSetupDialog', () {
    testWidgets('shows title "Set Up App Lock"', (tester) async {
      await tester.pumpWidget(buildDialog(onComplete: (_, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Set Up App Lock'), findsOneWidget);
    });

    testWidgets('shows PIN option', (tester) async {
      await tester.pumpWidget(buildDialog(onComplete: (_, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('PIN'), findsOneWidget);
      expect(find.text('6-digit code'), findsOneWidget);
    });

    testWidgets('hides biometrics when not available', (tester) async {
      await tester.pumpWidget(buildDialog(
        isBiometricAvailable: false,
        onComplete: (_, _) {},
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Biometrics'), findsNothing);
    });

    testWidgets('shows biometrics when available', (tester) async {
      await tester.pumpWidget(buildDialog(
        isBiometricAvailable: true,
        onComplete: (_, _) {},
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Biometrics'), findsOneWidget);
      expect(find.text('Fingerprint or Face ID'), findsOneWidget);
    });

    testWidgets('tapping biometrics calls onComplete and closes', (tester) async {
      AuthMethod? resultMethod;
      await tester.pumpWidget(buildDialog(
        isBiometricAvailable: true,
        onComplete: (method, pin) => resultMethod = method,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Biometrics'));
      await tester.pumpAndSettle();
      expect(resultMethod, AuthMethod.biometrics);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Cancel closes dialog', (tester) async {
      await tester.pumpWidget(buildDialog(onComplete: (_, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping PIN shows PIN input', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(buildDialog(onComplete: (_, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a 6-digit PIN'), findsOneWidget);
      expect(find.byType(PinInputWidget), findsOneWidget);
    });

    testWidgets('Back button closes dialog when no PIN entered', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(buildDialog(onComplete: (_, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Back'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
