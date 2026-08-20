import 'base_dao.dart';

class LoanDao extends BaseDao {
  LoanDao(super.getDb);

  Future<List<Map<String, dynamic>>> getLoans() async {
    final database = await db;
    return await database.query('loans', orderBy: 'loan_date DESC');
  }

  Future<Map<String, dynamic>?> getLoanById(String id) async {
    final database = await db;
    final maps = await database.query('loans', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> saveLoan(Map<String, dynamic> loan) async {
    final database = await db;
    final existing = await database.query(
      'loans',
      where: 'id = ?',
      whereArgs: [loan['id']],
    );
    if (existing.isNotEmpty) {
      await database.update(
        'loans',
        loan,
        where: 'id = ?',
        whereArgs: [loan['id']],
      );
    } else {
      await database.insert('loans', loan);
    }
  }

  Future<void> deleteLoan(String id) async {
    final database = await db;
    await database.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getLoansByDirection(String direction) async {
    final database = await db;
    return await database.query(
      'loans',
      where: 'direction = ?',
      whereArgs: [direction],
      orderBy: 'loan_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getLoansWithProjectionsEnabled() async {
    final database = await db;
    return await database.query(
      'loans',
      where: 'include_in_projections = ?',
      whereArgs: [1],
      orderBy: 'loan_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentsForLoan(String loanId) async {
    final database = await db;
    return await database.query(
      'loan_payments',
      where: 'loan_id = ?',
      whereArgs: [loanId],
      orderBy: 'payment_date DESC',
    );
  }

  Future<void> savePayment(Map<String, dynamic> payment) async {
    final database = await db;
    final existing = await database.query(
      'loan_payments',
      where: 'id = ?',
      whereArgs: [payment['id']],
    );
    if (existing.isNotEmpty) {
      await database.update(
        'loan_payments',
        payment,
        where: 'id = ?',
        whereArgs: [payment['id']],
      );
    } else {
      await database.insert('loan_payments', payment);
    }
  }

  Future<void> deletePayment(String id) async {
    final database = await db;
    await database.delete('loan_payments', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalPaymentsForLoan(String loanId) async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT SUM(amount) as total FROM loan_payments WHERE loan_id = ?',
      [loanId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
