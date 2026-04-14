import 'package:equatable/equatable.dart';

class SavingsGoal extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? linkedCategoryId;
  final String? icon;
  final String? color;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.linkedCategoryId,
    this.icon,
    this.color,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? linkedCategoryId,
    String? icon,
    String? color,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      linkedCategoryId: linkedCategoryId ?? this.linkedCategoryId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    targetAmount,
    currentAmount,
    deadline,
    linkedCategoryId,
    icon,
    color,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
