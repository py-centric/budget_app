import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/projection_bloc.dart';
import '../bloc/projection_event.dart';
import '../bloc/projection_state.dart';
import '../widgets/projection_table.dart';
import '../widgets/projection_chart.dart';
import '../widgets/recurring_instance_edit_dialog.dart';

class ProjectionPage extends StatelessWidget {
  const ProjectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projections'),
        actions: [
          BlocBuilder<ProjectionBloc, ProjectionState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<ProjectionBloc>().add(const LoadProjection());
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProjectionBloc, ProjectionState>(
        builder: (context, state) {
          if (state is ProjectionLoading || state is ProjectionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectionError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is ProjectionLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Granularity:'),
                      Switch(
                        value: state.isWeekly,
                        onChanged: (_) {
                          context.read<ProjectionBloc>().add(ToggleProjectionGranularity());
                        },
                      ),
                      Text(state.isWeekly ? 'Weekly' : 'Daily'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Horizon:'),
                      DropdownButton<String>(
                        value: state.settings.defaultProjectionHorizon,
                        items: const [
                          DropdownMenuItem(value: 'MONTH', child: Text('Current Month')),
                          DropdownMenuItem(value: '30_DAYS', child: Text('30 Days')),
                          DropdownMenuItem(value: '90_DAYS', child: Text('90 Days')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            context.read<ProjectionBloc>().add(ChangeProjectionHorizon(val));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Show Actuals:'),
                      Switch(
                        value: state.showActuals,
                        onChanged: (_) {
                          context.read<ProjectionBloc>().add(const ToggleShowActuals());
                        },
                      ),
                      const Text('Show Potential:'),
                      Switch(
                        value: state.showPotential,
                        onChanged: (_) {
                          context.read<ProjectionBloc>().add(const ToggleShowPotential());
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ProjectionChart(
                    points: state.points,
                    isWeekly: state.isWeekly,
                    showPotential: state.showPotential,
                  ),
                ),
                const Divider(),
                Expanded(
                  flex: 3,
                  child: ProjectionTable(
                    points: state.points,
                    isWeekly: state.isWeekly,
                    onEditInstance: (instance, originalDate) {
                      showDialog(
                        context: context,
                        builder: (context) => RecurringInstanceEditDialog(
                          instance: instance,
                          originalDate: originalDate,
                          onSave: (override) {
                            context.read<ProjectionBloc>().add(SaveOverride(override));
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
