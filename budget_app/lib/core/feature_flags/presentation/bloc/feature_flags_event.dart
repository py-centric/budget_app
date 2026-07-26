import 'package:equatable/equatable.dart';
import '../../models/release_edition.dart';

abstract class FeatureFlagsEvent extends Equatable {
  const FeatureFlagsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatureFlagsEvent extends FeatureFlagsEvent {
  const LoadFeatureFlagsEvent();
}

class SetRuntimeEditionOverrideEvent extends FeatureFlagsEvent {
  final ReleaseEdition? overrideEdition;

  const SetRuntimeEditionOverrideEvent(this.overrideEdition);

  @override
  List<Object?> get props => [overrideEdition];
}

class ClearRuntimeEditionOverrideEvent extends FeatureFlagsEvent {
  const ClearRuntimeEditionOverrideEvent();
}
