import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/feature_flag.dart';
import '../../models/release_edition.dart';
import '../bloc/feature_flags_bloc.dart';
import '../bloc/feature_flags_state.dart';

class FeatureGate extends StatelessWidget {
  final FeatureFlag? flag;
  final ReleaseEdition? edition;
  final Widget child;
  final Widget fallback;

  const FeatureGate({
    super.key,
    this.flag,
    this.edition,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  }) : assert(flag != null || edition != null, 'Must specify either flag or edition');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagsBloc, FeatureFlagsState>(
      builder: (context, state) {
        final isEnabled = flag != null
            ? state.isFeatureEnabled(flag!)
            : state.effectiveEdition == edition;

        return isEnabled ? child : fallback;
      },
    );
  }
}
