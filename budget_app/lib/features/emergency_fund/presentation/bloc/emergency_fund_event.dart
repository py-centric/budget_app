import 'package:equatable/equatable.dart';

abstract class EmergencyFundEvent extends Equatable {
  const EmergencyFundEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmergencyFund extends EmergencyFundEvent {}

class UpdateExpenseAmount extends EmergencyFundEvent {
  final String id;
  final double amount;

  const UpdateExpenseAmount(this.id, this.amount);

  @override
  List<Object> get props => [id, amount];
}

class AddCustomExpense extends EmergencyFundEvent {
  final String name;
  final double amount;
  final String? categoryType;

  const AddCustomExpense(this.name, this.amount, {this.categoryType});

  @override
  List<Object?> get props => [name, amount, categoryType];
}

class DeleteExpense extends EmergencyFundEvent {
  final String id;

  const DeleteExpense(this.id);

  @override
  List<Object> get props => [id];
}

class CalculateLivingExpenses extends EmergencyFundEvent {
  final int months;

  const CalculateLivingExpenses(this.months);

  @override
  List<Object> get props => [months];
}
