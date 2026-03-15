import 'package:equatable/equatable.dart';
import '../../../../core/utils/recurrence_calculator.dart';

class ProjectionPoint extends Equatable {
  final DateTime date;
  final double balance; // Legacy compatibility (maps to actualBalance)
  final double netChange; // Legacy compatibility (maps to netChangeActual)
  final double actualBalance;
  final double potentialBalance;
  final double netChangeActual;
  final double netChangePotential;
  final bool isWeekEnding;
  final List<RecurringInstance> recurringInstances;

  const ProjectionPoint({
    required this.date,
    required this.balance,
    required this.netChange,
    required this.actualBalance,
    required this.potentialBalance,
    required this.netChangeActual,
    required this.netChangePotential,
    required this.isWeekEnding,
    this.recurringInstances = const [],
  });

  bool get isNegative => actualBalance < 0;
  bool get isPotentialNegative => potentialBalance < 0;

  @override
  List<Object?> get props => [
        date,
        balance,
        netChange,
        actualBalance,
        potentialBalance,
        netChangeActual,
        netChangePotential,
        isWeekEnding,
        recurringInstances,
      ];
}
