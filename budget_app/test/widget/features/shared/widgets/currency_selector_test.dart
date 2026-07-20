import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/shared/widgets/currency_selector.dart';
import 'package:budget_app/shared/currencies.dart';

void main() {
  Widget buildDialog({String? initialValue, ValueChanged<Currency>? onSelected}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => CurrencySelector(
                initialValue: initialValue,
                onSelected: onSelected ?? (_) {},
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('CurrencySelector', () {
    testWidgets('shows title and search field', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('lists all currencies initially', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('GBP'), findsOneWidget);
    });

    testWidgets('search filters currencies by code', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'EUR');
      await tester.pumpAndSettle();
      // EUR appears in search field and list tile
      expect(find.text('EUR'), findsNWidgets(2));
      expect(find.text('USD'), findsNothing);
    });

    testWidgets('search filters currencies by name', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Pound');
      await tester.pumpAndSettle();
      expect(find.text('GBP'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
    });

    testWidgets('shows "No currencies found" for no matches', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ZZZZZ');
      await tester.pumpAndSettle();
      expect(find.text('No currencies found'), findsOneWidget);
    });

    testWidgets('clear button clears search', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'EUR');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('tapping a currency calls onSelected and closes', (tester) async {
      Currency? selected;
      await tester.pumpWidget(buildDialog(onSelected: (c) => selected = c));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR'));
      await tester.pumpAndSettle();
      expect(selected?.code, 'EUR');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Cancel closes dialog', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows currency symbols in list tiles', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('\$'), findsWidgets);
      expect(find.text('€'), findsOneWidget);
    });
  });
}
