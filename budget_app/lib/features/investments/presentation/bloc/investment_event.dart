import 'package:equatable/equatable.dart';
import '../../domain/entities/investment.dart';

abstract class InvestmentEvent extends Equatable {
  const InvestmentEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllInvestments extends InvestmentEvent {
  const LoadAllInvestments();
}

class AddInvestmentEvent extends InvestmentEvent {
  final String name;
  final String ticker;
  final double shares;
  final double avgCost;
  final double currentPrice;

  const AddInvestmentEvent({
    required this.name,
    required this.ticker,
    required this.shares,
    required this.avgCost,
    required this.currentPrice,
  });

  @override
  List<Object?> get props => [name, ticker, shares, avgCost, currentPrice];
}

class UpdateInvestmentEvent extends InvestmentEvent {
  final Investment investment;
  const UpdateInvestmentEvent(this.investment);
  @override
  List<Object?> get props => [investment];
}

class DeleteInvestmentEvent extends InvestmentEvent {
  final String investmentId;
  const DeleteInvestmentEvent(this.investmentId);
  @override
  List<Object?> get props => [investmentId];
}
