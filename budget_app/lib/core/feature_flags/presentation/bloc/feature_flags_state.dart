import 'package:equatable/equatable.dart';
import '../../models/feature_flag.dart';
import '../../models/release_edition.dart';
import '../../config/default_feature_mapping.dart';

class FeatureFlagsState extends Equatable {
  final ReleaseEdition defaultEdition;
  final ReleaseEdition? runtimeOverride;
  final Map<FeatureFlag, bool> activeFlags;

  const FeatureFlagsState({
    required this.defaultEdition,
    this.runtimeOverride,
    required this.activeFlags,
  });

  ReleaseEdition get effectiveEdition => runtimeOverride ?? defaultEdition;

  bool isFeatureEnabled(FeatureFlag flag) => activeFlags[flag] ?? false;

  factory FeatureFlagsState.initial({ReleaseEdition? defaultEdition}) {
    final edition = defaultEdition ??
        ReleaseEdition.fromString(
          const String.fromEnvironment('RELEASE_EDITION', defaultValue: 'combined'),
        );
    return FeatureFlagsState(
      defaultEdition: edition,
      runtimeOverride: null,
      activeFlags: DefaultFeatureMapping.resolveFlags(edition),
    );
  }

  FeatureFlagsState copyWith({
    ReleaseEdition? defaultEdition,
    ReleaseEdition? runtimeOverride,
    bool clearOverride = false,
    Map<FeatureFlag, bool>? activeFlags,
  }) {
    final newOverride = clearOverride ? null : (runtimeOverride ?? this.runtimeOverride);
    final newDefault = defaultEdition ?? this.defaultEdition;
    final effective = newOverride ?? newDefault;

    return FeatureFlagsState(
      defaultEdition: newDefault,
      runtimeOverride: newOverride,
      activeFlags: activeFlags ?? DefaultFeatureMapping.resolveFlags(effective),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultEdition': defaultEdition.name,
      'runtimeOverride': runtimeOverride?.name,
    };
  }

  factory FeatureFlagsState.fromJson(Map<String, dynamic> json) {
    final defaultEdition = ReleaseEdition.fromString(json['defaultEdition'] as String?);
    final runtimeOverride = json['runtimeOverride'] != null
        ? ReleaseEdition.fromString(json['runtimeOverride'] as String)
        : null;
    final effective = runtimeOverride ?? defaultEdition;

    return FeatureFlagsState(
      defaultEdition: defaultEdition,
      runtimeOverride: runtimeOverride,
      activeFlags: DefaultFeatureMapping.resolveFlags(effective),
    );
  }

  @override
  List<Object?> get props => [defaultEdition, runtimeOverride, activeFlags];
}
