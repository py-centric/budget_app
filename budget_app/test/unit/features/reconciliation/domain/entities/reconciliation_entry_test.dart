import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/reconciliation/domain/entities/reconciliation_entry.dart';

void main() {
  group('ReconciliationEntry', () {
    final now = DateTime(2024, 6, 15);
    final entry = ReconciliationEntry(
      id: 're-1',
      transactionId: 'tx-1',
      transactionType: 'expense',
      appAmount: 150.00,
      bankAmount: 150.00,
      date: now,
      status: ReconciliationStatus.reconciled,
      note: 'Verified',
    );

    test('props are correct', () {
      expect(entry.props, [
        're-1', 'tx-1', 'expense', 150.00, 150.00,
        now, ReconciliationStatus.reconciled, 'Verified',
      ]);
    });

    test('equality works', () {
      final entry2 = ReconciliationEntry(
        id: 're-1', transactionId: 'tx-1', transactionType: 'expense',
        appAmount: 150.00, bankAmount: 150.00, date: now,
        status: ReconciliationStatus.reconciled, note: 'Verified',
      );
      expect(entry, equals(entry2));
    });

    test('ReconciliationStatus has correct values', () {
      expect(ReconciliationStatus.values.length, 3);
      expect(ReconciliationStatus.values, contains(ReconciliationStatus.pending));
      expect(ReconciliationStatus.values, contains(ReconciliationStatus.reconciled));
      expect(ReconciliationStatus.values, contains(ReconciliationStatus.discrepancy));
    });

    test('default status is pending', () {
      final pending = ReconciliationEntry(
        id: 're-2', transactionId: 'tx-2', transactionType: 'expense',
        appAmount: 100, date: now,
      );
      expect(pending.status, ReconciliationStatus.pending);
    });

    test('nullable bankAmount', () {
      final noBank = ReconciliationEntry(
        id: 're-3', transactionId: 'tx-3', transactionType: 'expense',
        appAmount: 100, date: now,
      );
      expect(noBank.bankAmount, isNull);
    });

    test('nullable note', () {
      final noNote = ReconciliationEntry(
        id: 're-4', transactionId: 'tx-4', transactionType: 'income',
        appAmount: 200, date: now,
      );
      expect(noNote.note, isNull);
    });
  });
}
