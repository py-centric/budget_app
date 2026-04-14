import 'package:equatable/equatable.dart';

class SavingsContribution extends Equatable {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const SavingsContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  SavingsContribution copyWith({
    String? id,
    String? goalId,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return SavingsContribution(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, goalId, amount, date, note, createdAt];
}
