import '../../domain/entities/savings_contribution.dart';

class SavingsContributionModel extends SavingsContribution {
  const SavingsContributionModel({
    required super.id,
    required super.goalId,
    required super.amount,
    required super.date,
    super.note,
    required super.createdAt,
  });

  factory SavingsContributionModel.fromMap(Map<String, dynamic> map) {
    return SavingsContributionModel(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsContributionModel.fromEntity(SavingsContribution entity) {
    return SavingsContributionModel(
      id: entity.id,
      goalId: entity.goalId,
      amount: entity.amount,
      date: entity.date,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }
}
