import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../models/release_edition.dart';
import '../../config/default_feature_mapping.dart';
import 'feature_flags_event.dart';
import 'feature_flags_state.dart';

class FeatureFlagsBloc extends HydratedBloc<FeatureFlagsEvent, FeatureFlagsState> {
  FeatureFlagsBloc({ReleaseEdition? initialDefaultEdition})
      : super(FeatureFlagsState.initial(defaultEdition: initialDefaultEdition)) {
    on<LoadFeatureFlagsEvent>(_onLoadFeatureFlags);
    on<SetRuntimeEditionOverrideEvent>(_onSetRuntimeEditionOverride);
    on<ClearRuntimeEditionOverrideEvent>(_onClearRuntimeEditionOverride);
  }

  void _onLoadFeatureFlags(
    LoadFeatureFlagsEvent event,
    Emitter<FeatureFlagsState> emit,
  ) {
    emit(state);
  }

  void _onSetRuntimeEditionOverride(
    SetRuntimeEditionOverrideEvent event,
    Emitter<FeatureFlagsState> emit,
  ) {
    if (event.overrideEdition == null) {
      emit(state.copyWith(clearOverride: true));
    } else {
      final activeFlags = DefaultFeatureMapping.resolveFlags(event.overrideEdition!);
      emit(state.copyWith(
        runtimeOverride: event.overrideEdition,
        activeFlags: activeFlags,
      ));
    }
  }

  void _onClearRuntimeEditionOverride(
    ClearRuntimeEditionOverrideEvent event,
    Emitter<FeatureFlagsState> emit,
  ) {
    final activeFlags = DefaultFeatureMapping.resolveFlags(state.defaultEdition);
    emit(state.copyWith(
      clearOverride: true,
      activeFlags: activeFlags,
    ));
  }

  @override
  FeatureFlagsState? fromJson(Map<String, dynamic> json) {
    try {
      return FeatureFlagsState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(FeatureFlagsState state) {
    return state.toJson();
  }
}
