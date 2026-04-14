import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'filter_models.dart';

class AmountFilterControl extends StatefulWidget {
  final AmountFilter? initialValue;
  final ValueChanged<AmountFilter?> onChanged;
  final VoidCallback? onClear;

  const AmountFilterControl({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<AmountFilterControl> createState() => _AmountFilterControlState();
}

class _AmountFilterControlState extends State<AmountFilterControl> {
  late AmountOperator _selectedOperator;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _selectedOperator =
        widget.initialValue?.operator ?? AmountOperator.lessThan;
    _valueController = TextEditingController(
      text: widget.initialValue?.value.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _updateFilter() {
    final valueText = _valueController.text.trim();

    if (valueText.isEmpty) {
      widget.onChanged(null);
      return;
    }

    final value = double.tryParse(valueText);
    if (value == null || value < 0) {
      return;
    }

    widget.onChanged(AmountFilter(operator: _selectedOperator, value: value));
  }

  void _onOperatorChanged(AmountOperator? operator) {
    if (operator != null) {
      setState(() {
        _selectedOperator = operator;
      });
      _updateFilter();
    }
  }

  void _onValueChanged(String value) {
    _updateFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<AmountOperator>(
            initialValue: _selectedOperator,
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: AmountOperator.values.map((op) {
              return DropdownMenuItem(
                value: op,
                child: Text('${op.symbol} ${op.label}'),
              );
            }).toList(),
            onChanged: _onOperatorChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: _onValueChanged,
          ),
        ),
        if (widget.initialValue != null ||
            _valueController.text.isNotEmpty) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _valueController.clear();
              });
              widget.onClear?.call();
            },
            tooltip: 'Clear amount filter',
          ),
        ],
      ],
    );
  }
}
