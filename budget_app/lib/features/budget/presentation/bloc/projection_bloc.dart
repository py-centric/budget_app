import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/emergency_fund/domain/repositories/emergency_fund_repository.dart';
import 'projection_event.dart';
import 'projection_state.dart';
import '../../domain/usecases/calculate_projection.dart';
import '../../domain/usecases/apply_recurring_override.dart';
import '../../data/models/user_settings.dart';

class ProjectionBloc extends Bloc<ProjectionEvent, ProjectionState> {
  final CalculateProjection calculateProjection;
  final ApplyRecurringOverride applyRecurringOverride;
  final EmergencyFundRepository emergencyFundRepository;
  
  // Internal state tracking
  UserSettings _settings = const UserSettings();
  bool _isWeekly = false;
  bool _showActuals = false;
  bool _showPotential = true;
  double _emergencyFundTarget = 0.0;
  StreamSubscription<double>? _targetSubscription;

  ProjectionBloc({
    required this.calculateProjection,
    required this.applyRecurringOverride,
    required this.emergencyFundRepository,
  }) : super(ProjectionInitial()) {
    on<LoadProjection>(_onLoadProjection);
    on<ToggleProjectionGranularity>(_onToggleGranularity);
    on<ChangeProjectionHorizon>(_onChangeHorizon);
    on<ToggleShowActuals>(_onToggleShowActuals);
    on<ToggleShowPotential>(_onToggleShowPotential);
    on<SaveOverride>(_onSaveOverride);
    on<UpdateEmergencyTarget>(_onUpdateEmergencyTarget);

    _targetSubscription = emergencyFundRepository.watchTotalTarget().listen((target) {
      add(UpdateEmergencyTarget(target));
    });
  }

  Future<void> _onLoadProjection(LoadProjection event, Emitter<ProjectionState> emit) async {
    emit(ProjectionLoading());
    try {
      final points = await calculateProjection(
        settings: _settings,
        showActuals: _showActuals,
        today: DateTime.now(),
        budgetId: event.budgetId,
      );
      emit(ProjectionLoaded(
        points: points,
        isWeekly: _isWeekly,
        settings: _settings,
        showActuals: _showActuals,
        showPotential: _showPotential,
        emergencyFundTarget: _emergencyFundTarget,
      ));
    } catch (e) {
      emit(ProjectionError(e.toString()));
    }
  }

  void _onUpdateEmergencyTarget(UpdateEmergencyTarget event, Emitter<ProjectionState> emit) {
    _emergencyFundTarget = event.target;
    if (state is ProjectionLoaded) {
      emit((state as ProjectionLoaded).copyWith(emergencyFundTarget: _emergencyFundTarget));
    }
  }

  Future<void> _onToggleShowPotential(ToggleShowPotential event, Emitter<ProjectionState> emit) async {
    _showPotential = !_showPotential;
    if (state is ProjectionLoaded) {
      emit((state as ProjectionLoaded).copyWith(showPotential: _showPotential));
    } else {
      add(const LoadProjection());
    }
  }

  Future<void> _onToggleGranularity(ToggleProjectionGranularity event, Emitter<ProjectionState> emit) async {
    _isWeekly = !_isWeekly;
    if (state is ProjectionLoaded) {
      emit((state as ProjectionLoaded).copyWith(isWeekly: _isWeekly));
    } else {
      add(LoadProjection());
    }
  }

  Future<void> _onChangeHorizon(ChangeProjectionHorizon event, Emitter<ProjectionState> emit) async {
    _settings = _settings.copyWith(defaultProjectionHorizon: event.horizon);
    add(LoadProjection());
  }

  Future<void> _onToggleShowActuals(ToggleShowActuals event, Emitter<ProjectionState> emit) async {
    _showActuals = !_showActuals;
    add(LoadProjection());
  }

  Future<void> _onSaveOverride(SaveOverride event, Emitter<ProjectionState> emit) async {
    try {
      await applyRecurringOverride(event.recurringOverride);
      add(LoadProjection());
    } catch (e) {
      emit(ProjectionError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _targetSubscription?.cancel();
    return super.close();
  }
}

// Add UpdateEmergencyTarget to projection_event.dart as well
class UpdateEmergencyTarget extends ProjectionEvent {
  final double target;
  const UpdateEmergencyTarget(this.target);
  @override
  List<Object?> get props => [target];
}
