import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/loans/data/models/loan_model.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';

void main() {
  group('LoanModel', () {
    test('should create Loan fromMap', () {
      final map = {
        'id': '1',
        'borrower_name': 'John Doe',
        'loan_amount': 1000.0,
        'loan_date': '2024-01-01T00:00:00.000',
        'status': 'outstanding',
        'remaining_balance': 1000.0,
        'notes': 'Personal loan',
        'direction': 'lent',
        'include_in_projections': 0,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final loan = LoanModel.fromMap(map);

      expect(loan.id, '1');
      expect(loan.borrowerName, 'John Doe');
      expect(loan.loanAmount, 1000.0);
      expect(loan.status, LoanStatus.outstanding);
      expect(loan.direction, LoanDirection.lent);
      expect(loan.includeInProjections, false);
    });

    test('should handle different status values', () {
      final mapPartial = {
        'id': '1',
        'borrower_name': 'Test',
        'loan_amount': 100.0,
        'loan_date': '2024-01-01T00:00:00.000',
        'status': 'partial',
        'remaining_balance': 50.0,
        'direction': 'lent',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };
      expect(LoanModel.fromMap(mapPartial).status, LoanStatus.partial);

      final mapSettled = {
        'id': '1',
        'borrower_name': 'Test',
        'loan_amount': 100.0,
        'loan_date': '2024-01-01T00:00:00.000',
        'status': 'settled',
        'remaining_balance': 0.0,
        'direction': 'lent',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };
      expect(LoanModel.fromMap(mapSettled).status, LoanStatus.settled);
    });

    test('should handle direction owed', () {
      final map = {
        'id': '1',
        'borrower_name': 'Test',
        'loan_amount': 100.0,
        'loan_date': '2024-01-01T00:00:00.000',
        'status': 'outstanding',
        'remaining_balance': 100.0,
        'direction': 'owed',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      expect(LoanModel.fromMap(map).direction, LoanDirection.owed);
    });

    test('should handle includeInProjections true', () {
      final map = {
        'id': '1',
        'borrower_name': 'Test',
        'loan_amount': 100.0,
        'loan_date': '2024-01-01T00:00:00.000',
        'status': 'outstanding',
        'remaining_balance': 100.0,
        'direction': 'lent',
        'include_in_projections': 1,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      expect(LoanModel.fromMap(map).includeInProjections, true);
    });

    test('toMap should return correct map', () {
      final loan = Loan(
        id: '1',
        borrowerName: 'Test',
        loanAmount: 500.0,
        loanDate: DateTime(2024, 1, 1),
        status: LoanStatus.outstanding,
        remainingBalance: 500.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        direction: LoanDirection.lent,
        includeInProjections: true,
      );

      final map = LoanModel.toMap(loan);

      expect(map['id'], '1');
      expect(map['loan_amount'], 500.0);
      expect(map['status'], 'outstanding');
      expect(map['include_in_projections'], 1);
    });
  });
}
