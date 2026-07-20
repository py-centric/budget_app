import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/bill_splitting/domain/entities/bill_split.dart';

void main() {
  group('PersonSplit', () {
    test('props are correct', () {
      const ps = PersonSplit(name: 'Alice', amount: 40, isPaid: true);
      expect(ps.props, ['Alice', 40, true]);
    });

    test('default isPaid is false', () {
      const ps = PersonSplit(name: 'Bob', amount: 30);
      expect(ps.isPaid, isFalse);
    });

    test('copyWith creates new instance', () {
      const ps = PersonSplit(name: 'Alice', amount: 40);
      final updated = ps.copyWith(isPaid: true);
      expect(updated.isPaid, isTrue);
      expect(updated.name, 'Alice');
      expect(updated, isNot(equals(ps)));
    });

    test('copyWith with no args returns equal instance', () {
      const ps = PersonSplit(name: 'Alice', amount: 40);
      expect(ps.copyWith(), equals(ps));
    });

    test('toMap serializes correctly', () {
      const ps = PersonSplit(name: 'Alice', amount: 40, isPaid: true);
      final map = ps.toMap();
      expect(map['name'], 'Alice');
      expect(map['amount'], 40);
      expect(map['is_paid'], true);
    });

    test('fromMap deserializes correctly', () {
      final map = {'name': 'Alice', 'amount': 40, 'is_paid': true};
      final result = PersonSplit.fromMap(map);
      expect(result.name, 'Alice');
      expect(result.amount, 40);
      expect(result.isPaid, isTrue);
    });

    test('fromMap with is_paid false', () {
      final map = {'name': 'Bob', 'amount': 30, 'is_paid': false};
      final result = PersonSplit.fromMap(map);
      expect(result.isPaid, isFalse);
    });

    test('fromMap with null is_paid defaults to false', () {
      final map = {'name': 'Charlie', 'amount': 50, 'is_paid': null};
      final result = PersonSplit.fromMap(map);
      expect(result.isPaid, isFalse);
    });
  });

  group('BillSplit', () {
    final now = DateTime(2024, 6, 15);
    final billSplit = BillSplit(
      id: 'bs-1',
      transactionId: 'tx-1',
      description: 'Dinner',
      totalAmount: 120,
      splits: [
        const PersonSplit(name: 'Alice', amount: 40),
        const PersonSplit(name: 'Bob', amount: 40),
        const PersonSplit(name: 'Charlie', amount: 40),
      ],
      createdAt: now,
    );

    test('props are correct', () {
      expect(billSplit.props, [
        'bs-1', 'tx-1', 'Dinner', 120, billSplit.splits, now,
      ]);
    });

    test('totalSplit calculates correctly', () {
      expect(billSplit.totalSplit, 120);
    });

    test('remaining calculates correctly', () {
      expect(billSplit.remaining, 0);
    });

    test('remaining with uneven splits', () {
      final uneven = billSplit.copyWith(
        splits: [
          const PersonSplit(name: 'Alice', amount: 30),
          const PersonSplit(name: 'Bob', amount: 30),
        ],
      );
      expect(uneven.remaining, 60);
    });

    test('copyWith creates new instance', () {
      final updated = billSplit.copyWith(description: 'Lunch');
      expect(updated.description, 'Lunch');
      expect(updated.totalAmount, 120);
      expect(updated, isNot(equals(billSplit)));
    });

    test('copyWith with no args returns equal instance', () {
      expect(billSplit.copyWith(), equals(billSplit));
    });

    test('toMap serializes correctly', () {
      final map = billSplit.toMap();
      expect(map['id'], 'bs-1');
      expect(map['transaction_id'], 'tx-1');
      expect(map['description'], 'Dinner');
      expect(map['total_amount'], 120);
      expect(map['splits'], isA<List>());
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'bs-1', 'transaction_id': 'tx-1', 'description': 'Dinner',
        'total_amount': 120,
        'splits': [
          {'name': 'Alice', 'amount': 40, 'is_paid': false},
          {'name': 'Bob', 'amount': 40, 'is_paid': true},
        ],
        'created_at': now.toIso8601String(),
      };
      final result = BillSplit.fromMap(map);
      expect(result.id, 'bs-1');
      expect(result.description, 'Dinner');
      expect(result.splits.length, 2);
      expect(result.splits[0].name, 'Alice');
      expect(result.splits[1].isPaid, isTrue);
    });

    test('fromMap with null transaction_id', () {
      final map = {
        'id': 'bs-2', 'transaction_id': null, 'description': 'Lunch',
        'total_amount': 80, 'splits': null,
        'created_at': now.toIso8601String(),
      };
      final result = BillSplit.fromMap(map);
      expect(result.transactionId, isNull);
      expect(result.splits, isEmpty);
    });
  });
}
