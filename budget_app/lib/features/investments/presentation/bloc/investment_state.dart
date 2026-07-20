import 'package:equatable/equatable.dart';
import '../../domain/entities/investment.dart';

abstract class InvestmentState extends Equatable {
  const InvestmentState();
  @override
  List<Object?> get props => [];
}

class InvestmentInitial extends InvestmentState {
  const InvestmentInitial();
}

class InvestmentLoading extends InvestmentState {
  const InvestmentLoading();
}

class InvestmentLoaded extends InvestmentState {
  final List<Investment> investments;
  const InvestmentLoaded(this.investments);
  @override
  List<Object?> get props => [investments];
}

class InvestmentError extends InvestmentState {
  final String message;
  const InvestmentError(this.message);
  @override
  List<Object?> get props => [message];
}
