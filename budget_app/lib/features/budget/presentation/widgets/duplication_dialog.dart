import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget_period.dart';
import '../../domain/entities/budget.dart';
import '../budget_bloc.dart';
import '../budget_event.dart';

class DuplicationDialog extends StatefulWidget {
  final Budget sourceBudget;

  const DuplicationDialog({super.key, required this.sourceBudget});

  @override
  State<DuplicationDialog> createState() => _DuplicationDialogState();
}

class _DuplicationDialogState extends State<DuplicationDialog> {
  late TextEditingController _nameController;
  late int _selectedMonth;
  late int _selectedYear;
  bool _includeTransactions = true;
  late String _selectedCurrency;

  static const List<Map<String, String>> supportedCurrencies = [
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
    _nameController = TextEditingController(
      text: '${widget.sourceBudget.name} - Copy',
    );
    final nextPeriod = BudgetPeriod(
      year: widget.sourceBudget.periodYear,
      month: widget.sourceBudget.periodMonth,
    ).next;
    _selectedMonth = nextPeriod.month;
    _selectedYear = nextPeriod.year;
    _selectedCurrency = widget.sourceBudget.currencyCode ?? 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Budget'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'New Budget Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: supportedCurrencies.map((currency) {
                return DropdownMenuItem(
                  value: currency['code'],
                  child: Text(
                    '${currency['symbol']} ${currency['code']} - ${currency['name']}',
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCurrency = val);
              },
            ),
            const SizedBox(height: 16),
            const Text('Target Period:'),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text('Month ${index + 1}'),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMonth = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isExpanded: true,
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Transactions'),
              subtitle: const Text(
                'Copies all individual entries shifted to the new month.',
              ),
              value: _includeTransactions,
              onChanged: (val) => setState(() => _includeTransactions = val),
              contentPadding: EdgeInsets.zero,
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
            context.read<BudgetBloc>().add(
              DuplicateBudgetEvent(
                sourceBudget: widget.sourceBudget.copyWith(
                  currencyCode: _selectedCurrency,
                ),
                targetPeriod: BudgetPeriod(
                  year: _selectedYear,
                  month: _selectedMonth,
                ),
                newName: _nameController.text,
                includeTransactions: _includeTransactions,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Duplicate'),
        ),
      ],
    );
  }
}
