import 'package:equatable/equatable.dart';

class RecurringTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type;
  final double defaultAmount;
  final String defaultCategoryId;
  final int defaultInterval;
  final String defaultUnit;

  const RecurringTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.defaultAmount,
    required this.defaultCategoryId,
    this.defaultInterval = 1,
    this.defaultUnit = 'months',
  });

  @override
  List<Object?> get props => [id, name, description, type, defaultAmount, defaultCategoryId, defaultInterval, defaultUnit];
}
