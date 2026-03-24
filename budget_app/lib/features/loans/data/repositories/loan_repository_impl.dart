import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import 'package:budget_app/features/loans/data/models/loan_model.dart';
import 'package:budget_app/features/loans/data/models/loan_payment_model.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';
import 'package:budget_app/features/loans/domain/entities/loan_summary.dart';
import 'package:budget_app/features/loans/domain/repositories/loan_repository.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LocalDatabase _localDatabase;

  LoanRepositoryImpl(this._localDatabase);

  @override
  Future<List<Loan>> getLoans() async {
    final db = await _localDatabase.database;
    final maps = await db.query('loans', orderBy: 'loan_date DESC');
    return maps.map((map) => LoanModel.fromMap(map)).toList();
  }

  @override
  Future<Loan?> getLoanById(String id) async {
    final db = await _localDatabase.database;
    final maps = await db.query('loans', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return LoanModel.fromMap(maps.first);
  }

  @override
  Future<void> saveLoan(Loan loan) async {
    final db = await _localDatabase.database;
    final existing = await db.query(
      'loans',
      where: 'id = ?',
      whereArgs: [loan.id],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'loans',
        LoanModel.toMap(loan),
        where: 'id = ?',
        whereArgs: [loan.id],
      );
    } else {
      await db.insert('loans', LoanModel.toMap(loan));
    }
  }

  @override
  Future<void> deleteLoan(String id) async {
    final db = await _localDatabase.database;
    await db.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<LoanSummary> getLoanSummary() async {
    final db = await _localDatabase.database;

    final allLoans = await db.query('loans');
    final loans = allLoans.map((map) => LoanModel.fromMap(map)).toList();

    double totalOutstanding = 0;
    int settledCount = 0;
    int outstandingCount = 0;
    int partialCount = 0;

    for (final loan in loans) {
      if (loan.status == LoanStatus.settled) {
        settledCount++;
      } else {
        totalOutstanding += loan.remainingBalance;
        if (loan.status == LoanStatus.outstanding) {
          outstandingCount++;
        } else if (loan.status == LoanStatus.partial) {
          partialCount++;
        }
      }
    }

    return LoanSummary(
      totalOutstanding: totalOutstanding,
      totalLoans: loans.length,
      settledCount: settledCount,
      outstandingCount: outstandingCount,
      partialCount: partialCount,
    );
  }

  @override
  Future<List<Loan>> getLoansByDirection(LoanDirection direction) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'loans',
      where: 'direction = ?',
      whereArgs: [direction.name],
      orderBy: 'loan_date DESC',
    );
    return maps.map((map) => LoanModel.fromMap(map)).toList();
  }

  @override
  Future<List<Loan>> getLoansWithProjectionsEnabled() async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'loans',
      where: 'include_in_projections = ?',
      whereArgs: [1],
      orderBy: 'loan_date DESC',
    );
    return maps.map((map) => LoanModel.fromMap(map)).toList();
  }

  @override
  Future<List<LoanPayment>> getPaymentsForLoan(String loanId) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'loan_payments',
      where: 'loan_id = ?',
      whereArgs: [loanId],
      orderBy: 'payment_date DESC',
    );
    return maps.map((map) => LoanPaymentModel.fromMap(map)).toList();
  }

  @override
  Future<void> savePayment(LoanPayment payment) async {
    final db = await _localDatabase.database;
    final existing = await db.query(
      'loan_payments',
      where: 'id = ?',
      whereArgs: [payment.id],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'loan_payments',
        LoanPaymentModel.toMap(payment),
        where: 'id = ?',
        whereArgs: [payment.id],
      );
    } else {
      await db.insert('loan_payments', LoanPaymentModel.toMap(payment));
    }

    await _updateLoanBalanceAndStatus(payment.loanId);
  }

  @override
  Future<void> deletePayment(String id) async {
    final db = await _localDatabase.database;
    final payments = await db.query(
      'loan_payments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (payments.isNotEmpty) {
      final loanId = payments.first['loan_id'] as String;
      await db.delete('loan_payments', where: 'id = ?', whereArgs: [id]);
      await _updateLoanBalanceAndStatus(loanId);
    }
  }

  @override
  Future<double> getTotalPaymentsForLoan(String loanId) async {
    final db = await _localDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM loan_payments WHERE loan_id = ?',
      [loanId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<void> _updateLoanBalanceAndStatus(String loanId) async {
    final db = await _localDatabase.database;
    final loanMaps = await db.query(
      'loans',
      where: 'id = ?',
      whereArgs: [loanId],
    );
    if (loanMaps.isEmpty) return;

    final loan = LoanModel.fromMap(loanMaps.first);
    final totalPayments = await getTotalPaymentsForLoan(loanId);

    double newRemainingBalance = loan.loanAmount - totalPayments;
    if (newRemainingBalance < 0) newRemainingBalance = 0;

    LoanStatus newStatus;
    if (totalPayments >= loan.loanAmount) {
      newStatus = LoanStatus.settled;
      newRemainingBalance = 0;
    } else if (totalPayments > 0) {
      newStatus = LoanStatus.partial;
    } else {
      newStatus = LoanStatus.outstanding;
    }

    final updatedLoan = loan.copyWith(
      remainingBalance: newRemainingBalance,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await db.update(
      'loans',
      LoanModel.toMap(updatedLoan),
      where: 'id = ?',
      whereArgs: [loanId],
    );
  }
}
