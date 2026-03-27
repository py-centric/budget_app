import 'package:equatable/equatable.dart';

class Transfer extends Equatable {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    fromAccountId,
    toAccountId,
    amount,
    date,
    note,
    createdAt,
  ];
}
