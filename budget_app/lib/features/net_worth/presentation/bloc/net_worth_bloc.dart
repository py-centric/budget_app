import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/net_worth_snapshot.dart';
import '../../domain/repositories/net_worth_repository.dart';
import 'net_worth_event.dart';
import 'net_worth_state.dart';

class NetWorthBloc extends Bloc<NetWorthEvent, NetWorthState> {
  final NetWorthRepository _repository;
  final _uuid = const Uuid();

  NetWorthBloc({required NetWorthRepository repository})
      : _repository = repository,
        super(const NetWorthInitial()) {
    on<LoadNetWorthSnapshots>(_onLoadSnapshots);
    on<AddNetWorthSnapshotEvent>(_onAddSnapshot);
  }

  Future<void> _onLoadSnapshots(LoadNetWorthSnapshots event, Emitter<NetWorthState> emit) async {
    final snapshots = await _repository.getSnapshots(limit: 24);
    final current = snapshots.isNotEmpty ? snapshots.first.netWorth : 0.0;
    emit(NetWorthLoaded(snapshots: snapshots, currentNetWorth: current));
  }

  Future<void> _onAddSnapshot(AddNetWorthSnapshotEvent event, Emitter<NetWorthState> emit) async {
    final snapshot = NetWorthSnapshot(
      id: _uuid.v4(),
      date: DateTime.now(),
      totalAssets: event.totalAssets,
      totalLiabilities: event.totalLiabilities,
      netWorth: event.totalAssets - event.totalLiabilities,
    );
    await _repository.addSnapshot(snapshot);
    final snapshots = await _repository.getSnapshots(limit: 24);
    final current = snapshots.isNotEmpty ? snapshots.first.netWorth : 0.0;
    emit(NetWorthLoaded(snapshots: snapshots, currentNetWorth: current));
  }
}
