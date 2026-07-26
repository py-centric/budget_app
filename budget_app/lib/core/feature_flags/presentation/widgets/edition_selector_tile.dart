import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/release_edition.dart';
import '../bloc/feature_flags_bloc.dart';
import '../bloc/feature_flags_event.dart';
import '../bloc/feature_flags_state.dart';

class EditionSelectorTile extends StatelessWidget {
  const EditionSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagsBloc, FeatureFlagsState>(
      builder: (context, state) {
        final currentEdition = state.effectiveEdition;
        final hasOverride = state.runtimeOverride != null;

        return ListTile(
          leading: const Icon(Icons.apps),
          title: const Text('Release Edition Override'),
          subtitle: Text(
            hasOverride
                ? '${currentEdition.label} (Runtime Override)'
                : '${currentEdition.label} (Build Default)',
          ),
          trailing: DropdownButton<ReleaseEdition?>(
            value: state.runtimeOverride,
            hint: Text(state.defaultEdition.label),
            items: [
              const DropdownMenuItem<ReleaseEdition?>(
                value: null,
                child: Text('Default (Build Flavor)'),
              ),
              ...ReleaseEdition.values.map(
                (edition) => DropdownMenuItem<ReleaseEdition?>(
                  value: edition,
                  child: Text(edition.label),
                ),
              ),
            ],
            onChanged: (newEdition) {
              context.read<FeatureFlagsBloc>().add(
                    SetRuntimeEditionOverrideEvent(newEdition),
                  );
            },
          ),
        );
      },
    );
  }
}
