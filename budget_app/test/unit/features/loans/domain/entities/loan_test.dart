import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';

void main() {
  group('Loan', () {
    test('should create Loan with required fields', () {
      final loan = Loan(
        id: '1',
        borrowerName: 'John Doe',
        loanAmount: 1000.0,
        loanDate: DateTime(2024, 1, 1),
        status: LoanStatus.outstanding,
        remainingBalance: 1000.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(loan.id, '1');
      expect(loan.borrowerName, 'John Doe');
      expect(loan.loanAmount, 1000.0);
      expect(loan.status, LoanStatus.outstanding);
      expect(loan.remainingBalance, 1000.0);
      expect(loan.direction, LoanDirection.lent);
      expect(loan.includeInProjections, false);
    });

    test('should create Loan with all fields', () {
      final loan = Loan(
        id: '1',
        borrowerName: 'Jane Smith',
        loanAmount: 5000.0,
        loanDate: DateTime(2024, 1, 15),
        status: LoanStatus.partial,
        remainingBalance: 2500.0,
        notes: 'Personal loan',
        direction: LoanDirection.owed,
        includeInProjections: true,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 2, 1),
      );

      expect(loan.borrowerName, 'Jane Smith');
      expect(loan.status, LoanStatus.partial);
      expect(loan.notes, 'Personal loan');
      expect(loan.direction, LoanDirection.owed);
      expect(loan.includeInProjections, true);
    });

    test('copyWith should create a copy with updated fields', () {
      final original = Loan(
        id: '1',
        borrowerName: 'Original Name',
        loanAmount: 1000.0,
        loanDate: DateTime(2024, 1, 1),
        status: LoanStatus.outstanding,
        remainingBalance: 1000.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final copied = original.copyWith(
        borrowerName: 'New Name',
        status: LoanStatus.settled,
        remainingBalance: 0.0,
      );

      expect(copied.id, '1');
      expect(copied.borrowerName, 'New Name');
      expect(copied.status, LoanStatus.settled);
      expect(copied.remainingBalance, 0.0);
      expect(copied.loanAmount, 1000.0);
    });

    test('two loans with same values should be equal', () {
      final loan1 = Loan(
        id: '1',
        borrowerName: 'Test',
        loanAmount: 100.0,
        loanDate: DateTime(2024, 1, 1),
        status: LoanStatus.outstanding,
        remainingBalance: 100.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final loan2 = Loan(
        id: '1',
        borrowerName: 'Test',
        loanAmount: 100.0,
        loanDate: DateTime(2024, 1, 1),
        status: LoanStatus.outstanding,
        remainingBalance: 100.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(loan1, equals(loan2));
      expect(loan1.hashCode, equals(loan2.hashCode));
    });
  });

  group('LoanStatus', () {
    test('displayName returns correct values', () {
      expect(LoanStatus.outstanding.displayName, 'Outstanding');
      expect(LoanStatus.partial.displayName, 'Partial');
      expect(LoanStatus.settled.displayName, 'Settled');
    });

    test('fromString returns correct values', () {
      expect(LoanStatus.fromString('outstanding'), LoanStatus.outstanding);
      expect(LoanStatus.fromString('partial'), LoanStatus.partial);
      expect(LoanStatus.fromString('settled'), LoanStatus.settled);
      expect(LoanStatus.fromString('unknown'), LoanStatus.outstanding);
    });
  });

  group('LoanDirection', () {
    test('displayName returns correct values', () {
      expect(LoanDirection.lent.displayName, 'Lent by Me');
      expect(LoanDirection.owed.displayName, 'Owed to Me');
    });

    test('fromString returns correct values', () {
      expect(LoanDirection.fromString('lent'), LoanDirection.lent);
      expect(LoanDirection.fromString('owed'), LoanDirection.owed);
      expect(LoanDirection.fromString('unknown'), LoanDirection.lent);
    });
  });
}
