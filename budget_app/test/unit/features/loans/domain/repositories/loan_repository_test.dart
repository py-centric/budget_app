import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/loans/domain/repositories/loan_repository.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';
import 'package:budget_app/features/loans/domain/entities/loan_summary.dart';

class MockLoanRepository extends Mock implements LoanRepository {}

class FakeLoan extends Fake implements Loan {}

class FakeLoanPayment extends Fake implements LoanPayment {}

void main() {
  late MockLoanRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeLoan());
    registerFallbackValue(FakeLoanPayment());
  });

  setUp(() {
    mockRepository = MockLoanRepository();
  });

  group('LoanRepository', () {
    test('getLoans should return list of loans', () async {
      final loans = [
        Loan(
          id: '1',
          borrowerName: 'John Doe',
          loanAmount: 1000.0,
          loanDate: DateTime(2024, 1, 1),
          status: LoanStatus.outstanding,
          remainingBalance: 1000.0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

      when(() => mockRepository.getLoans()).thenAnswer((_) async => loans);

      final result = await mockRepository.getLoans();

      expect(result, loans);
      expect(result.length, 1);
    });

    test('getLoanById should return loan by id', () async {
      final loan = Loan(
        id: '1',
        borrowerName: 'Jane Smith',
        loanAmount: 5000.0,
        loanDate: DateTime(2024, 1, 15),
        status: LoanStatus.partial,
        remainingBalance: 2500.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 2, 1),
      );

      when(() => mockRepository.getLoanById('1')).thenAnswer((_) async => loan);

      final result = await mockRepository.getLoanById('1');

      expect(result, loan);
      expect(result!.borrowerName, 'Jane Smith');
    });

    test('getLoanById should return null for unknown id', () async {
      when(
        () => mockRepository.getLoanById('unknown'),
      ).thenAnswer((_) async => null);

      final result = await mockRepository.getLoanById('unknown');

      expect(result, isNull);
    });

    test('saveLoan should call repository', () async {
      when(() => mockRepository.saveLoan(any())).thenAnswer((_) async {});

      final loan = Loan(
        id: '1',
        borrowerName: 'Test',
        loanAmount: 100.0,
        loanDate: DateTime(2024, 1, 1),
        status: LoanStatus.outstanding,
        remainingBalance: 100.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await mockRepository.saveLoan(loan);

      verify(() => mockRepository.saveLoan(loan)).called(1);
    });

    test('deleteLoan should call repository', () async {
      when(() => mockRepository.deleteLoan('1')).thenAnswer((_) async {});

      await mockRepository.deleteLoan('1');

      verify(() => mockRepository.deleteLoan('1')).called(1);
    });

    test('getLoanSummary should return summary', () async {
      const summary = LoanSummary(
        totalOutstanding: 5000.0,
        totalLoans: 5,
        settledCount: 1,
        outstandingCount: 3,
        partialCount: 1,
      );

      when(
        () => mockRepository.getLoanSummary(),
      ).thenAnswer((_) async => summary);

      final result = await mockRepository.getLoanSummary();

      expect(result.totalOutstanding, 5000.0);
      expect(result.totalLoans, 5);
    });

    test('getLoansByDirection should filter by direction', () async {
      final loans = [
        Loan(
          id: '1',
          borrowerName: 'Test',
          loanAmount: 100.0,
          loanDate: DateTime(2024, 1, 1),
          status: LoanStatus.outstanding,
          remainingBalance: 100.0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          direction: LoanDirection.lent,
        ),
      ];

      when(
        () => mockRepository.getLoansByDirection(LoanDirection.lent),
      ).thenAnswer((_) async => loans);

      final result = await mockRepository.getLoansByDirection(
        LoanDirection.lent,
      );

      expect(result.length, 1);
      expect(result.first.direction, LoanDirection.lent);
    });

    test('getPaymentsForLoan should return payments', () async {
      final payments = [
        LoanPayment(
          id: '1',
          loanId: 'loan-1',
          amount: 100.0,
          paymentDate: DateTime(2024, 2, 1),
          createdAt: DateTime(2024, 2, 1),
        ),
      ];

      when(
        () => mockRepository.getPaymentsForLoan('loan-1'),
      ).thenAnswer((_) async => payments);

      final result = await mockRepository.getPaymentsForLoan('loan-1');

      expect(result, payments);
      expect(result.length, 1);
    });

    test('savePayment should call repository', () async {
      when(() => mockRepository.savePayment(any())).thenAnswer((_) async {});

      final payment = LoanPayment(
        id: '1',
        loanId: 'loan-1',
        amount: 50.0,
        paymentDate: DateTime(2024, 2, 1),
        createdAt: DateTime(2024, 2, 1),
      );

      await mockRepository.savePayment(payment);

      verify(() => mockRepository.savePayment(payment)).called(1);
    });

    test('getTotalPaymentsForLoan should return sum', () async {
      when(
        () => mockRepository.getTotalPaymentsForLoan('loan-1'),
      ).thenAnswer((_) async => 500.0);

      final result = await mockRepository.getTotalPaymentsForLoan('loan-1');

      expect(result, 500.0);
    });
  });
}
