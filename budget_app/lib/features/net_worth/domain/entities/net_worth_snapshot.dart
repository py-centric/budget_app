import 'package:equatable/equatable.dart';

class NetWorthSnapshot extends Equatable {
  final String id;
  final DateTime date;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;

  const NetWorthSnapshot({
    required this.id,
    required this.date,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  factory NetWorthSnapshot.fromMap(Map<String, dynamic> map) {
    return NetWorthSnapshot(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      totalAssets: (map['total_assets'] as num).toDouble(),
      totalLiabilities: (map['total_liabilities'] as num).toDouble(),
      netWorth: (map['net_worth'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total_assets': totalAssets,
      'total_liabilities': totalLiabilities,
      'net_worth': netWorth,
    };
  }

  @override
  List<Object?> get props => [id, date, totalAssets, totalLiabilities, netWorth];
}
