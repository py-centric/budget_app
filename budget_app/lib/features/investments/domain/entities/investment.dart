import 'package:equatable/equatable.dart';

class Investment extends Equatable {
  final String id;
  final String name;
  final String ticker;
  final double shares;
  final double avgCost;
  final double currentPrice;

  const Investment({
    required this.id,
    required this.name,
    required this.ticker,
    required this.shares,
    required this.avgCost,
    required this.currentPrice,
  });

  double get totalCost => shares * avgCost;
  double get totalValue => shares * currentPrice;
  double get roi => totalCost > 0 ? ((totalValue - totalCost) / totalCost * 100) : 0;
  double get gainLoss => totalValue - totalCost;

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'] as String,
      name: map['name'] as String,
      ticker: map['ticker'] as String,
      shares: (map['shares'] as num).toDouble(),
      avgCost: (map['avg_cost'] as num).toDouble(),
      currentPrice: (map['current_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ticker': ticker,
      'shares': shares,
      'avg_cost': avgCost,
      'current_price': currentPrice,
    };
  }

  Investment copyWith({
    String? id,
    String? name,
    String? ticker,
    double? shares,
    double? avgCost,
    double? currentPrice,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      ticker: ticker ?? this.ticker,
      shares: shares ?? this.shares,
      avgCost: avgCost ?? this.avgCost,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  @override
  List<Object?> get props => [id, name, ticker, shares, avgCost, currentPrice];
}
