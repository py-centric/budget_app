import 'package:equatable/equatable.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_override.dart';

abstract class ProjectionEvent extends Equatable {
  const ProjectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjection extends ProjectionEvent {
  final String? budgetId;
  const LoadProjection({this.budgetId});

  @override
  List<Object?> get props => [budgetId];
}

class ToggleProjectionGranularity extends ProjectionEvent {
  const ToggleProjectionGranularity();
}

class ChangeProjectionHorizon extends ProjectionEvent {
  final String horizon;
  const ChangeProjectionHorizon(this.horizon);

  @override
  List<Object?> get props => [horizon];
}

class ToggleShowActuals extends ProjectionEvent {
  const ToggleShowActuals();
}

class ToggleShowPotential extends ProjectionEvent {
  const ToggleShowPotential();
}

class SaveOverride extends ProjectionEvent {
  final RecurringOverride recurringOverride;
  const SaveOverride(this.recurringOverride);
  @override
  List<Object> get props => [recurringOverride];
}

class UpdateEmergencyTarget extends ProjectionEvent {
  final double target;
  const UpdateEmergencyTarget(this.target);
  @override
  List<Object?> get props => [target];
}
