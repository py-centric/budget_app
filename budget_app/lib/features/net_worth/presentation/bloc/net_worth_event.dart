import 'package:equatable/equatable.dart';
import '../../domain/entities/net_worth_snapshot.dart';

abstract class NetWorthEvent extends Equatable {
  const NetWorthEvent();
  @override
  List<Object?> get props => [];
}

class LoadNetWorthSnapshots extends NetWorthEvent {
  const LoadNetWorthSnapshots();
}

class AddNetWorthSnapshotEvent extends NetWorthEvent {
  final double totalAssets;
  final double totalLiabilities;
  const AddNetWorthSnapshotEvent({required this.totalAssets, required this.totalLiabilities});
  @override
  List<Object?> get props => [totalAssets, totalLiabilities];
}
