import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';

void main() {
  group('Transfer', () {
    test('should create Transfer with required fields', () {
      final transfer = Transfer(
        id: '1',
        fromAccountId: 'acc1',
        toAccountId: 'acc2',
        amount: 100.0,
        date: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
      );

      expect(transfer.id, '1');
      expect(transfer.fromAccountId, 'acc1');
      expect(transfer.toAccountId, 'acc2');
      expect(transfer.amount, 100.0);
      expect(transfer.note, isNull);
    });

    test('should create Transfer with optional note', () {
      final transfer = Transfer(
        id: '1',
        fromAccountId: 'acc1',
        toAccountId: 'acc2',
        amount: 50.0,
        date: DateTime(2024, 1, 15),
        note: 'Monthly savings',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(transfer.note, 'Monthly savings');
    });
  });
}
