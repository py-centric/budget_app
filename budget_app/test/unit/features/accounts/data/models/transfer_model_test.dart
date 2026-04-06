import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/data/models/transfer_model.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';

void main() {
  group('TransferModel', () {
    test('should create TransferModel with required fields', () {
      final model = TransferModel(
        id: '1',
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 500.0,
        date: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
      );

      expect(model.id, '1');
      expect(model.fromAccountId, 'acc-1');
      expect(model.toAccountId, 'acc-2');
      expect(model.amount, 500.0);
      expect(model.note, isNull);
    });

    test('should create TransferModel with note', () {
      final model = TransferModel(
        id: '1',
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 1000.0,
        date: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
        note: 'Transfer for savings',
      );

      expect(model.note, 'Transfer for savings');
    });

    test('should create TransferModel fromMap', () {
      final map = {
        'id': '1',
        'from_account_id': 'acc-1',
        'to_account_id': 'acc-2',
        'amount': 750.0,
        'date': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'note': 'Test note',
        'created_at': DateTime(2024, 1, 15).millisecondsSinceEpoch,
      };

      final model = TransferModel.fromMap(map);

      expect(model.id, '1');
      expect(model.fromAccountId, 'acc-1');
      expect(model.toAccountId, 'acc-2');
      expect(model.amount, 750.0);
      expect(model.note, 'Test note');
    });

    test('toMap should return correct map', () {
      final model = TransferModel(
        id: '1',
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 250.0,
        date: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
        note: 'Note',
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['from_account_id'], 'acc-1');
      expect(map['to_account_id'], 'acc-2');
      expect(map['amount'], 250.0);
      expect(map['note'], 'Note');
    });

    test('fromEntity should create model from entity', () {
      final entity = Transfer(
        id: '1',
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 500.0,
        date: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
        note: 'Entity note',
      );

      final model = TransferModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.fromAccountId, 'acc-1');
      expect(model.amount, 500.0);
      expect(model.note, 'Entity note');
    });

    test('TransferModel should be a subtype of Transfer', () {
      final model = TransferModel(
        id: '1',
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      expect(model, isA<Transfer>());
    });
  });
}
