import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/budget.dart';
import '../budget_bloc.dart';
import '../budget_event.dart';

class CurrencyConversionDialog extends StatefulWidget {
  final Budget budget;

  const CurrencyConversionDialog({super.key, required this.budget});

  @override
  State<CurrencyConversionDialog> createState() =>
      _CurrencyConversionDialogState();
}

class _CurrencyConversionDialogState extends State<CurrencyConversionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _exchangeRateController;
  String _selectedTargetCurrency = 'EUR';

  static const List<Map<String, String>> allCurrencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': '\$'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': '\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'Fr'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
    {'code': 'MXN', 'name': 'Mexican Peso', 'symbol': '\$'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$'},
    {'code': 'KRW', 'name': 'South Korean Won', 'symbol': '₩'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': '\$'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar', 'symbol': '\$'},
    {'code': 'SEK', 'name': 'Swedish Krona', 'symbol': 'kr'},
    {'code': 'ZAR', 'name': 'South African Rand', 'symbol': 'R'},
    {'code': 'NZD', 'name': 'New Zealand Dollar', 'symbol': '\$'},
    {'code': 'NOK', 'name': 'Norwegian Krone', 'symbol': 'kr'},
    {'code': 'DKK', 'name': 'Danish Krone', 'symbol': 'kr'},
    {'code': 'THB', 'name': 'Thai Baht', 'symbol': '฿'},
  ];

  @override
  void initState() {
    super.initState();
    _exchangeRateController = TextEditingController(
      text: widget.budget.exchangeRate?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final sourceCurrency = settingsState.settings.currencyCode;

        final availableTargets = allCurrencies
            .where((c) => c['code'] != sourceCurrency)
            .toList();

        if (_selectedTargetCurrency == sourceCurrency ||
            !availableTargets.any(
              (c) => c['code'] == _selectedTargetCurrency,
            )) {
          _selectedTargetCurrency = availableTargets.isNotEmpty
              ? availableTargets.first['code']!
              : 'EUR';
        }

        return AlertDialog(
          title: const Text('Convert Budget Currency'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: $sourceCurrency',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTargetCurrency,
                  decoration: const InputDecoration(labelText: 'Convert to'),
                  items: availableTargets.map((currency) {
                    return DropdownMenuItem(
                      value: currency['code'],
                      child: Text(
                        '${currency['symbol']} ${currency['code']} - ${currency['name']}',
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedTargetCurrency = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _exchangeRateController,
                  decoration: InputDecoration(
                    labelText: 'Exchange Rate',
                    helperText:
                        '1 $sourceCurrency = ? $_selectedTargetCurrency',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an exchange rate';
                    }
                    final rate = double.tryParse(value);
                    if (rate == null || rate <= 0) {
                      return 'Exchange rate must be greater than zero';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final exchangeRate = double.parse(
                    _exchangeRateController.text,
                  );
                  context.read<BudgetBloc>().add(
                    ConvertBudgetEvent(
                      budgetId: widget.budget.id,
                      targetCurrencyCode: _selectedTargetCurrency,
                      exchangeRate: exchangeRate,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Convert'),
            ),
          ],
        );
      },
    );
  }
}
