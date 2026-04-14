import 'package:equatable/equatable.dart';

enum LimitPeriod { weekly, monthly }

class CategoryLimit extends Equatable {
  final String id;
  final String categoryId;
  final double amount;
  final LimitPeriod period;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryLimit({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.createdAt,
    required this.updatedAt,
  });

  CategoryLimit copyWith({
    String? id,
    String? categoryId,
    double? amount,
    LimitPeriod? period,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryLimit(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    amount,
    period,
    createdAt,
    updatedAt,
  ];
}
