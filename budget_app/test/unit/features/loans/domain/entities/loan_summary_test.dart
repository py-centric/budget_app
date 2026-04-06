import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/loans/domain/entities/loan_summary.dart';

void main() {
  group('LoanSummary', () {
    test('should create LoanSummary with all fields', () {
      const summary = LoanSummary(
        totalOutstanding: 5000.0,
        totalLoans: 10,
        settledCount: 3,
        outstandingCount: 5,
        partialCount: 2,
      );

      expect(summary.totalOutstanding, 5000.0);
      expect(summary.totalLoans, 10);
      expect(summary.settledCount, 3);
      expect(summary.outstandingCount, 5);
      expect(summary.partialCount, 2);
    });

    test('empty factory should create zero summary', () {
      final summary = LoanSummary.empty();

      expect(summary.totalOutstanding, 0.0);
      expect(summary.totalLoans, 0);
      expect(summary.settledCount, 0);
      expect(summary.outstandingCount, 0);
      expect(summary.partialCount, 0);
    });

    test('two summaries with same values should be equal', () {
      const summary1 = LoanSummary(
        totalOutstanding: 1000.0,
        totalLoans: 5,
        settledCount: 1,
        outstandingCount: 3,
        partialCount: 1,
      );

      const summary2 = LoanSummary(
        totalOutstanding: 1000.0,
        totalLoans: 5,
        settledCount: 1,
        outstandingCount: 3,
        partialCount: 1,
      );

      expect(summary1, equals(summary2));
      expect(summary1.hashCode, equals(summary2.hashCode));
    });

    test('two summaries with different values should not be equal', () {
      const summary1 = LoanSummary(
        totalOutstanding: 1000.0,
        totalLoans: 5,
        settledCount: 1,
        outstandingCount: 3,
        partialCount: 1,
      );

      const summary2 = LoanSummary(
        totalOutstanding: 2000.0,
        totalLoans: 5,
        settledCount: 1,
        outstandingCount: 3,
        partialCount: 1,
      );

      expect(summary1, isNot(equals(summary2)));
    });
  });
}
