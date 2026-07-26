import '../models/feature_flag.dart';
import '../models/release_edition.dart';
import '../presentation/bloc/feature_flags_bloc.dart';
import 'feature_gate_service.dart';

class FeatureGateServiceImpl implements FeatureGateService {
  final FeatureFlagsBloc _featureFlagsBloc;

  FeatureGateServiceImpl(this._featureFlagsBloc);

  @override
  bool isFeatureEnabled(FeatureFlag flag) {
    return _featureFlagsBloc.state.isFeatureEnabled(flag);
  }

  @override
  bool isEditionActive(ReleaseEdition edition) {
    return _featureFlagsBloc.state.effectiveEdition == edition;
  }

  @override
  ReleaseEdition get effectiveEdition {
    return _featureFlagsBloc.state.effectiveEdition;
  }
}
