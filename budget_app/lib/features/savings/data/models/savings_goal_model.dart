import '../../domain/entities/savings_goal.dart';

class SavingsGoalModel extends SavingsGoal {
  const SavingsGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    super.currentAmount,
    super.deadline,
    super.linkedCategoryId,
    super.icon,
    super.color,
    super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      linkedCategoryId: map['linked_category_id'] as String?,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      isCompleted: (map['is_completed'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'linked_category_id': linkedCategoryId,
      'icon': icon,
      'color': color,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromEntity(SavingsGoal entity) {
    return SavingsGoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadline: entity.deadline,
      linkedCategoryId: entity.linkedCategoryId,
      icon: entity.icon,
      color: entity.color,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
