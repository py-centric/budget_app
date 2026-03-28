import 'package:flutter/material.dart';
import 'package:budget_app/shared/currencies.dart';

class CurrencySelector extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<Currency> onSelected;

  const CurrencySelector({
    super.key,
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _filteredCurrencies = Currencies.all;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _searchController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    setState(() {
      _filteredCurrencies = Currencies.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Currency'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search currency...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterCurrencies('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterCurrencies,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredCurrencies.isEmpty
                  ? const Center(child: Text('No currencies found'))
                  : ListView.builder(
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = _filteredCurrencies[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text(currency.symbol)),
                          title: Text(currency.code),
                          subtitle: Text(currency.name),
                          onTap: () {
                            widget.onSelected(currency);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

Future<Currency?> showCurrencySelector(
  BuildContext context, {
  String? initialValue,
}) {
  return showDialog<Currency>(
    context: context,
    builder: (context) => CurrencySelector(
      initialValue: initialValue,
      onSelected: (currency) {
        Navigator.of(context).pop(currency);
      },
    ),
  );
}
