import 'package:equatable/equatable.dart';
import '../../domain/entities/projection_point.dart';
import '../../data/models/user_settings.dart';

abstract class ProjectionState extends Equatable {
  const ProjectionState();

  @override
  List<Object?> get props => [];
}

class ProjectionInitial extends ProjectionState {}

class ProjectionLoading extends ProjectionState {}

class ProjectionLoaded extends ProjectionState {
  final List<ProjectionPoint> points;
  final bool isWeekly;
  final UserSettings settings;
  final bool showActuals;
  final bool showPotential;
  final double emergencyFundTarget;

  const ProjectionLoaded({
    required this.points,
    required this.isWeekly,
    required this.settings,
    required this.showActuals,
    this.showPotential = true,
    this.emergencyFundTarget = 0.0,
  });

  ProjectionLoaded copyWith({
    List<ProjectionPoint>? points,
    bool? isWeekly,
    UserSettings? settings,
    bool? showActuals,
    bool? showPotential,
    double? emergencyFundTarget,
  }) {
    return ProjectionLoaded(
      points: points ?? this.points,
      isWeekly: isWeekly ?? this.isWeekly,
      settings: settings ?? this.settings,
      showActuals: showActuals ?? this.showActuals,
      showPotential: showPotential ?? this.showPotential,
      emergencyFundTarget: emergencyFundTarget ?? this.emergencyFundTarget,
    );
  }

  @override
  List<Object?> get props => [
    points, 
    isWeekly, 
    settings, 
    showActuals, 
    showPotential, 
    emergencyFundTarget
  ];
}

class ProjectionError extends ProjectionState {
  final String message;

  const ProjectionError(this.message);

  @override
  List<Object?> get props => [message];
}
