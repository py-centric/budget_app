import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/budget/presentation/widgets/filter_models.dart';
import 'package:budget_app/features/budget/presentation/widgets/account_filter_sheet.dart';

void main() {
  final testAccounts = [
    Account(
      id: 'acc_1',
      name: 'Main Checking',
      type: AccountType.checking,
      balance: 1500.0,
      currency: 'USD',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Account(
      id: 'acc_2',
      name: 'Savings Goal',
      type: AccountType.savings,
      balance: 10000.0,
      currency: 'USD',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  Widget createWidgetUnderTest({
    required AccountFilter initialFilter,
    required ValueChanged<AccountFilter> onApply,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AccountFilterSheet(
          accounts: testAccounts,
          initialFilter: initialFilter,
          onApply: onApply,
        ),
      ),
    );
  }

  group('AccountFilterSheet Widget Tests', () {
    testWidgets('renders all accounts and unassigned option', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialFilter: const AccountFilter(),
          onApply: (_) {},
        ),
      );

      expect(find.text('Filter by Account'), findsOneWidget);
      expect(find.text('Unassigned'), findsOneWidget);
      expect(find.text('Main Checking'), findsOneWidget);
      expect(find.text('Savings Goal'), findsOneWidget);
    });

    testWidgets('allows multi-selecting accounts and applying filter', (tester) async {
      AccountFilter? appliedFilter;

      await tester.pumpWidget(
        createWidgetUnderTest(
          initialFilter: const AccountFilter(),
          onApply: (filter) {
            appliedFilter = filter;
          },
        ),
      );

      // Tap 'Main Checking' and 'Unassigned'
      await tester.tap(find.text('Main Checking'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unassigned'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(appliedFilter, isNotNull);
      expect(appliedFilter!.selectedAccountIds, contains('acc_1'));
      expect(appliedFilter!.includeUnassigned, isTrue);
      expect(appliedFilter!.selectedAccountIds.contains('acc_2'), isFalse);
    });

    testWidgets('Clear All resets selections', (tester) async {
      AccountFilter? appliedFilter;

      await tester.pumpWidget(
        createWidgetUnderTest(
          initialFilter: const AccountFilter(
            selectedAccountIds: {'acc_1', 'acc_2'},
            includeUnassigned: true,
          ),
          onApply: (filter) {
            appliedFilter = filter;
          },
        ),
      );

      // Tap Clear All
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(appliedFilter, isNotNull);
      expect(appliedFilter!.isActive, isFalse);
    });
  });
}
