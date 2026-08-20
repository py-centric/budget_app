import 'package:flutter/material.dart';
import '../../../accounts/domain/entities/account.dart';
import 'filter_models.dart';

class AccountFilterSheet extends StatefulWidget {
  final List<Account> accounts;
  final AccountFilter initialFilter;
  final ValueChanged<AccountFilter> onApply;

  const AccountFilterSheet({
    super.key,
    required this.accounts,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<AccountFilterSheet> createState() => _AccountFilterSheetState();
}

class _AccountFilterSheetState extends State<AccountFilterSheet> {
  late Set<String> _selectedAccountIds;
  late bool _includeUnassigned;

  @override
  void initState() {
    super.initState();
    _selectedAccountIds = Set<String>.from(widget.initialFilter.selectedAccountIds);
    _includeUnassigned = widget.initialFilter.includeUnassigned;
  }

  void _handleToggleAccount(String id) {
    setState(() {
      if (_selectedAccountIds.contains(id)) {
        _selectedAccountIds.remove(id);
      } else {
        _selectedAccountIds.add(id);
      }
    });
  }

  void _handleToggleUnassigned() {
    setState(() {
      _includeUnassigned = !_includeUnassigned;
    });
  }

  void _handleClearAll() {
    setState(() {
      _selectedAccountIds.clear();
      _includeUnassigned = false;
    });
  }

  void _handleApply() {
    final filter = AccountFilter(
      selectedAccountIds: _selectedAccountIds,
      includeUnassigned: _includeUnassigned,
    );
    widget.onApply(filter);
    Navigator.of(context).maybePop(filter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Account',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const Divider(),
            CheckboxListTile(
              secondary: const Icon(Icons.money_off),
              title: const Text('Unassigned'),
              subtitle: const Text('Transactions without an assigned account'),
              value: _includeUnassigned,
              onChanged: (_) => _handleToggleUnassigned(),
            ),
            if (widget.accounts.isNotEmpty) ...[
              const Divider(),
              ...widget.accounts.map(
                (account) => CheckboxListTile(
                  secondary: const Icon(Icons.account_balance),
                  title: Text(account.name),
                  subtitle: Text(account.type.displayName),
                  value: _selectedAccountIds.contains(account.id),
                  onChanged: (_) => _handleToggleAccount(account.id),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleClearAll,
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleApply,
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
