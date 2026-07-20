import 'package:equatable/equatable.dart';
import '../../domain/entities/net_worth_snapshot.dart';

abstract class NetWorthState extends Equatable {
  const NetWorthState();
  @override
  List<Object?> get props => [];
}

class NetWorthInitial extends NetWorthState {
  const NetWorthInitial();
}

class NetWorthLoaded extends NetWorthState {
  final List<NetWorthSnapshot> snapshots;
  final double currentNetWorth;
  const NetWorthLoaded({required this.snapshots, required this.currentNetWorth});
  @override
  List<Object?> get props => [snapshots, currentNetWorth];
}
