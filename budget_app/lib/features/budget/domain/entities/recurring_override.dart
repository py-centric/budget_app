import 'package:equatable/equatable.dart';

class RecurringOverride extends Equatable {
  final String id;
  final String recurringTransactionId;
  final DateTime targetDate;
  final double? newAmount;
  final DateTime? newDate;
  final bool isDeleted;

  const RecurringOverride({
    required this.id,
    required this.recurringTransactionId,
    required this.targetDate,
    this.newAmount,
    this.newDate,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        recurringTransactionId,
        targetDate,
        newAmount,
        newDate,
        isDeleted,
      ];
}
