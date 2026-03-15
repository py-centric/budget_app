import 'package:equatable/equatable.dart';
import '../../domain/entities/projection_point.dart';

class HomeProjectionState extends Equatable {
  final List<ProjectionPoint> points;
  final String currentHorizon; // "MONTH", "7_DAYS", "30_DAYS"
  final bool isExpanded;

  const HomeProjectionState({
    required this.points,
    this.currentHorizon = 'MONTH',
    this.isExpanded = false,
  });

  HomeProjectionState copyWith({
    List<ProjectionPoint>? points,
    String? currentHorizon,
    bool? isExpanded,
  }) {
    return HomeProjectionState(
      points: points ?? this.points,
      currentHorizon: currentHorizon ?? this.currentHorizon,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  List<Object?> get props => [points, currentHorizon, isExpanded];
}
