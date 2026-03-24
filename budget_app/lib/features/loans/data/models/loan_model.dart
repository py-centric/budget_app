import '../../domain/entities/loan.dart';

class LoanModel {
  static Loan fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as String,
      borrowerName: map['borrower_name'] as String,
      loanAmount: (map['loan_amount'] as num).toDouble(),
      loanDate: DateTime.parse(map['loan_date'] as String),
      status: LoanStatus.fromString(map['status'] as String),
      remainingBalance: (map['remaining_balance'] as num).toDouble(),
      notes: map['notes'] as String?,
      direction: LoanDirection.fromString(
        map['direction'] as String? ?? 'lent',
      ),
      includeInProjections: (map['include_in_projections'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toMap(Loan loan) {
    return {
      'id': loan.id,
      'borrower_name': loan.borrowerName,
      'loan_amount': loan.loanAmount,
      'loan_date': loan.loanDate.toIso8601String(),
      'status': loan.status.name,
      'remaining_balance': loan.remainingBalance,
      'notes': loan.notes,
      'direction': loan.direction.name,
      'include_in_projections': loan.includeInProjections ? 1 : 0,
      'created_at': loan.createdAt.toIso8601String(),
      'updated_at': loan.updatedAt.toIso8601String(),
    };
  }
}
