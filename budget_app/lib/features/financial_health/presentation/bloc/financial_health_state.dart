import 'package:equatable/equatable.dart';
import '../../domain/entities/financial_health_score.dart';

abstract class FinancialHealthState extends Equatable {
  const FinancialHealthState();
  @override
  List<Object?> get props => [];
}

class FinancialHealthInitial extends FinancialHealthState {
  const FinancialHealthInitial();
}

class FinancialHealthLoaded extends FinancialHealthState {
  final FinancialHealthScore score;
  const FinancialHealthLoaded(this.score);
  @override
  List<Object?> get props => [score];
}
