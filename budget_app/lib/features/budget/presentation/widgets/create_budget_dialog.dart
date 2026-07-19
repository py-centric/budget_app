import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/navigation_bloc.dart';

class CreateBudgetDialog extends StatefulWidget {
  const CreateBudgetDialog({super.key});

  @override
  State<CreateBudgetDialog> createState() => _CreateBudgetDialogState();
}

class _CreateBudgetDialogState extends State<CreateBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isMultiMonth = false;
  int _selectedMonth = DateTime.now().month;
  int _startMonth = 1;
  int _endMonth = 12;
  String? _appliedPreset;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _yearController.text = now.year.toString();
    _nameController.text = 'Main Budget';
  }

  @override
  void dispose() {
    _yearController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    final year = int.tryParse(_yearController.text) ?? DateTime.now().year;
    setState(() {
      _appliedPreset = preset;
      switch (preset) {
        case 'Q1':
          _startMonth = 1;
          _endMonth = 3;
          _nameController.text = 'Q1 $year Budget';
        case 'Q2':
          _startMonth = 4;
          _endMonth = 6;
          _nameController.text = 'Q2 $year Budget';
        case 'Q3':
          _startMonth = 7;
          _endMonth = 9;
          _nameController.text = 'Q3 $year Budget';
        case 'Q4':
          _startMonth = 10;
          _endMonth = 12;
          _nameController.text = 'Q4 $year Budget';
        case 'Year':
          _startMonth = 1;
          _endMonth = 12;
          _nameController.text = '$year Budget';
        case 'Custom':
          _nameController.text = 'Budget $year';
      }
    });
  }

  List<int> _getMonthsList() {
    if (!_isMultiMonth) return <int>[_selectedMonth];
    return List.generate(
      _endMonth - _startMonth + 1,
      (i) => _startMonth + i,
    );
  }

  void _onCreate() {
    if (!_formKey.currentState!.validate()) return;

    if (_isMultiMonth && _endMonth < _startMonth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End month must be on or after start month'),
        ),
      );
      return;
    }

    final year = int.parse(_yearController.text);
    final months = _getMonthsList();
    final name = _nameController.text.trim();

    context.read<NavigationBloc>().add(
      CreateBudget(
        name: name,
        year: year,
        month: _isMultiMonth ? 0 : months.first,
        months: _isMultiMonth ? months : const <int>[],
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Budget created for $name')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Budget'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SwitchListTile(
                title: const Text('Multiple months'),
                value: _isMultiMonth,
                onChanged: (val) => setState(() => _isMultiMonth = val),
                contentPadding: EdgeInsets.zero,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter a year';
                  final year = int.tryParse(value);
                  if (year == null || year <= 2000 || year > 2100) {
                    return 'Year must be between 2001 and 2100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isMultiMonth)
                DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  decoration: const InputDecoration(labelText: 'Month'),
                  items: List.generate(12, (i) {
                    return DropdownMenuItem<int>(
                      value: i + 1,
                      child: Text(_monthNames[i]),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMonth = val);
                  },
                ),
              if (_isMultiMonth) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _startMonth,
                        decoration: const InputDecoration(
                          labelText: 'Start Month',
                        ),
                        items: List.generate(12, (i) {
                          return DropdownMenuItem<int>(
                            value: i + 1,
                            child: Text(_monthNames[i]),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _startMonth = val;
                              if (_endMonth < val) _endMonth = val;
                              _appliedPreset = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _endMonth,
                        decoration: const InputDecoration(
                          labelText: 'End Month',
                        ),
                        items: List.generate(12, (i) {
                          return DropdownMenuItem<int>(
                            value: i + 1,
                            child: Text(_monthNames[i]),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _endMonth = val;
                              _appliedPreset = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    _buildPresetChip('Q1'),
                    _buildPresetChip('Q2'),
                    _buildPresetChip('Q3'),
                    _buildPresetChip('Q4'),
                    _buildPresetChip('Year'),
                    _buildPresetChip('Custom'),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Budget Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a budget name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onCreate,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label) {
    final isSelected = _appliedPreset == label;
    return FilterChip(
      label: Text(_presetLabel(label)),
      selected: isSelected,
      onSelected: (_) => _applyPreset(label),
    );
  }

  String _presetLabel(String preset) {
    switch (preset) {
      case 'Q1':
        return 'Q1 (Jan\u2013Mar)';
      case 'Q2':
        return 'Q2 (Apr\u2013Jun)';
      case 'Q3':
        return 'Q3 (Jul\u2013Sep)';
      case 'Q4':
        return 'Q4 (Oct\u2013Dec)';
      case 'Year':
        return 'Year (Jan\u2013Dec)';
      case 'Custom':
        return 'Custom\u2026';
      default:
        return preset;
    }
  }
}
