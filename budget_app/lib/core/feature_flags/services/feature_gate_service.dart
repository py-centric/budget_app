import '../models/feature_flag.dart';
import '../models/release_edition.dart';

abstract class FeatureGateService {
  /// Evaluates whether the specified [flag] is active under the current release edition.
  bool isFeatureEnabled(FeatureFlag flag);

  /// Evaluates whether the requested [edition] is currently active.
  bool isEditionActive(ReleaseEdition edition);

  /// Gets the current effective release edition (considering build flags and runtime overrides).
  ReleaseEdition get effectiveEdition;
}
