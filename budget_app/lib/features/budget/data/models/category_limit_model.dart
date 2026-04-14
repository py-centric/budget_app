import '../../domain/entities/category_limit.dart';

class CategoryLimitModel extends CategoryLimit {
  const CategoryLimitModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    required super.period,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryLimitModel.fromMap(Map<String, dynamic> map) {
    return CategoryLimitModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      period: map['period'] == 'weekly'
          ? LimitPeriod.weekly
          : LimitPeriod.monthly,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'period': period == LimitPeriod.weekly ? 'weekly' : 'monthly',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CategoryLimitModel.fromEntity(CategoryLimit entity) {
    return CategoryLimitModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      period: entity.period,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
