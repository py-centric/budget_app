import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';

class EmergencyExpenseModel extends EmergencyExpense {
  const EmergencyExpenseModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.isSuggestion,
    super.categoryType,
    required super.sortOrder,
  });

  factory EmergencyExpenseModel.fromMap(Map<String, dynamic> map) {
    return EmergencyExpenseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      isSuggestion: (map['is_suggestion'] as int) == 1,
      categoryType: map['category_type'] as String?,
      sortOrder: map['sort_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'is_suggestion': isSuggestion ? 1 : 0,
      'category_type': categoryType,
      'sort_order': sortOrder,
    };
  }

  factory EmergencyExpenseModel.fromEntity(EmergencyExpense entity) {
    return EmergencyExpenseModel(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      isSuggestion: entity.isSuggestion,
      categoryType: entity.categoryType,
      sortOrder: entity.sortOrder,
    );
  }
}
