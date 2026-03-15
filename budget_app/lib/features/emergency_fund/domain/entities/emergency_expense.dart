import 'package:equatable/equatable.dart';

class EmergencyExpense extends Equatable {
  final String id;
  final String name;
  final double amount;
  final bool isSuggestion;
  final String? categoryType;
  final int sortOrder;

  const EmergencyExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.isSuggestion,
    this.categoryType,
    required this.sortOrder,
  });

  EmergencyExpense copyWith({
    String? id,
    String? name,
    double? amount,
    bool? isSuggestion,
    String? categoryType,
    int? sortOrder,
  }) {
    return EmergencyExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isSuggestion: isSuggestion ?? this.isSuggestion,
      categoryType: categoryType ?? this.categoryType,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, name, amount, isSuggestion, categoryType, sortOrder];
}
