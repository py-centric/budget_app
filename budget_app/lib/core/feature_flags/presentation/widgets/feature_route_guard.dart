import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/feature_flag.dart';
import '../bloc/feature_flags_bloc.dart';
import '../bloc/feature_flags_state.dart';

class FeatureRouteGuard extends StatelessWidget {
  final FeatureFlag flag;
  final Widget child;

  const FeatureRouteGuard({
    super.key,
    required this.flag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagsBloc, FeatureFlagsState>(
      builder: (context, state) {
        if (state.isFeatureEnabled(flag)) {
          return child;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Feature Unavailable'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Feature Not Available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This feature is not included in the active ${state.effectiveEdition.label}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
