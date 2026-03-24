import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/export_configuration.dart';
import '../../domain/entities/export_format.dart';
import '../../domain/entities/export_period.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportPeriod _selectedPeriod = ExportPeriod.currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state.hasError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state.isSuccess) {
          _showSuccessActions(context);
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Export Budget'),
          content: SizedBox(
            width: double.maxFinite,
            child: state.isLoading || state.isGenerating
                ? _buildLoadingState()
                : _buildConfigurationForm(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ExportBloc>().add(ExportReset());
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            if (!state.isLoading && !state.isGenerating)
              ElevatedButton(onPressed: _onExport, child: const Text('Export')),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Preparing export...'),
      ],
    );
  }

  Widget _buildConfigurationForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Format:'),
        const SizedBox(height: 8),
        SegmentedButton<ExportFormat>(
          segments: ExportFormat.values
              .map((f) => ButtonSegment(value: f, label: Text(f.displayName)))
              .toList(),
          selected: {_selectedFormat},
          onSelectionChanged: (selection) {
            setState(() {
              _selectedFormat = selection.first;
            });
          },
        ),
        const SizedBox(height: 16),
        const Text('Period:'),
        const SizedBox(height: 8),
        DropdownButtonFormField<ExportPeriod>(
          initialValue: _selectedPeriod,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: ExportPeriod.values
              .map(
                (p) => DropdownMenuItem(value: p, child: Text(p.displayName)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
            }
          },
        ),
        if (_selectedPeriod == ExportPeriod.customRange) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _selectDate(true),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}'
                        : 'Start Date',
                  ),
                ),
              ),
              const Text(' - '),
              Expanded(
                child: TextButton(
                  onPressed: () => _selectDate(false),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}'
                        : 'End Date',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _onExport() {
    final config = ExportConfiguration(
      period: _selectedPeriod,
      format: _selectedFormat,
      startDate: _startDate,
      endDate: _endDate,
    );
    context.read<ExportBloc>().add(ExportConfigure(config));
    context.read<ExportBloc>().add(ExportGenerate());
  }

  void _showSuccessActions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Complete'),
        content: const Text('Your budget has been exported successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ExportBloc>().add(ExportShare());
              Navigator.of(ctx).pop();
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
