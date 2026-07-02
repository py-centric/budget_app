import 'package:flutter/material.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/shared/widgets/empty_state_widget.dart';
import 'slidable_transaction_item.dart';

class CategoryGroupedList extends StatefulWidget {
  final List<dynamic> entries;
  final bool isExpense;
  final String currencyCode;
  final Function(dynamic) onEdit;
  final Function(dynamic) onDelete;
  final Function(dynamic)? onConfirm;

  const CategoryGroupedList({
    super.key,
    required this.entries,
    required this.isExpense,
    required this.currencyCode,
    required this.onEdit,
    required this.onDelete,
    this.onConfirm,
  });

  @override
  State<CategoryGroupedList> createState() => _CategoryGroupedListState();
}

class _CategoryGroupedListState extends State<CategoryGroupedList> {
  final Set<String> _collapsedCategories = {};

  String? _getCategoryId(dynamic entry) {
    if (entry is ExpenseEntry) return entry.categoryId;
    if (entry is IncomeEntry) return entry.categoryId;
    return null;
  }

  String? _getCategoryName(dynamic entry) {
    if (entry is ExpenseEntry) return entry.categoryName;
    if (entry is IncomeEntry) return entry.categoryName;
    return null;
  }

  String? _getCategoryIcon(dynamic entry) {
    if (entry is ExpenseEntry) return entry.categoryIcon;
    if (entry is IncomeEntry) return entry.categoryIcon;
    return null;
  }

  double _getAmount(dynamic entry) {
    if (entry is ExpenseEntry) return entry.amount;
    if (entry is IncomeEntry) return entry.amount;
    return 0;
  }

  IconData _categoryIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return widget.isExpense ? Icons.money_off : Icons.attach_money;
    }
    final iconMap = <String, IconData>{
      'attach_money': Icons.attach_money,
      'card_giftcard': Icons.card_giftcard,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'shopping_cart': Icons.shopping_cart,
      'flight': Icons.flight,
      'school': Icons.school,
      'medical_services': Icons.medical_services,
      'sports_esports': Icons.sports_esports,
      'checkroom': Icons.checkroom,
      'pets': Icons.pets,
      'fitness_center': Icons.fitness_center,
      'local_pharmacy': Icons.local_pharmacy,
      'electrical_services': Icons.electrical_services,
      'handyman': Icons.handyman,
      'payments': Icons.payments,
      'savings': Icons.savings,
      'work': Icons.work,
      'business': Icons.business,
      'money_off': Icons.money_off,
    };
    return iconMap[iconName] ??
        (widget.isExpense ? Icons.money_off : Icons.attach_money);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return EmptyStateWidget(
        message: widget.isExpense
            ? 'No expense entries yet.\nAdd your first expense!'
            : 'No income entries yet.\nAdd your first income!',
        icon: widget.isExpense ? Icons.money_off : Icons.attach_money,
      );
    }

    final theme = Theme.of(context);
    final groupColor = widget.isExpense
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    final Map<String, List<dynamic>> groups = {};
    for (final entry in widget.entries) {
      final catId = _getCategoryId(entry) ?? '__uncategorized__';
      groups.putIfAbsent(catId, () => []);
      groups[catId]!.add(entry);
    }

    final sortedGroupKeys = groups.keys.toList()..sort((a, b) {
      final aTotal = groups[a]!.fold<double>(0, (s, e) => s + _getAmount(e));
      final bTotal = groups[b]!.fold<double>(0, (s, e) => s + _getAmount(e));
      return bTotal.compareTo(aTotal);
    });

    final totalAll = widget.entries.fold<double>(
      0,
      (sum, e) => sum + _getAmount(e),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...sortedGroupKeys.map((catId) {
          final groupEntries = groups[catId]!;
          final firstEntry = groupEntries.first;
          final catName = _getCategoryName(firstEntry) ?? 'Uncategorized';
          final catIcon = _getCategoryIcon(firstEntry);
          final groupTotal = groupEntries.fold<double>(
            0,
            (sum, e) => sum + _getAmount(e),
          );
          final isCollapsed = _collapsedCategories.contains(catId);

          return Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (isCollapsed) {
                      _collapsedCategories.remove(catId);
                    } else {
                      _collapsedCategories.add(catId);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: groupColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _categoryIcon(catIcon),
                          size: 18,
                          color: groupColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          catName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                          groupTotal,
                          currencyCode: widget.currencyCode,
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: groupColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: isCollapsed ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isCollapsed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Column(
                  children: groupEntries.map((entry) {
                    return _buildEntryItem(entry, theme);
                  }).toList(),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          );
        }),
        const Divider(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyFormatter.format(
                  totalAll,
                  currencyCode: widget.currencyCode,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: groupColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntryItem(dynamic entry, ThemeData theme) {
    if (entry is ExpenseEntry) {
      return _buildExpenseItem(entry, theme);
    }
    if (entry is IncomeEntry) {
      return _buildIncomeItem(entry, theme);
    }
    return const SizedBox.shrink();
  }

  Widget _buildExpenseItem(ExpenseEntry entry, ThemeData theme) {
    return SlidableTransactionItem(
      key: ValueKey(entry.id),
      isIncome: false,
      onTap: () => widget.onEdit(entry),
      onEdit: () => widget.onEdit(entry),
      onDelete: () => widget.onDelete(entry),
      onConfirm: entry.isPotential ? () => widget.onConfirm?.call(entry) : null,
      child: Opacity(
        opacity: entry.isPotential ? 0.7 : 1.0,
        child: Card(
          shape: entry.isPotential
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                )
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: entry.isPotential
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.errorContainer,
              child: Icon(
                entry.isPotential ? Icons.help_outline : Icons.arrow_upward,
                color: entry.isPotential
                    ? theme.colorScheme.outline
                    : theme.colorScheme.onErrorContainer,
              ),
            ),
            title: Row(
              children: [
                Text(
                  CurrencyFormatter.format(
                    entry.amount,
                    currencyCode: widget.currencyCode,
                  ),
                ),
                if (entry.isPotential)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '(Potential)',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category: ${entry.categoryName ?? entry.categoryId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (entry.description != null) Text(entry.description!),
              ],
            ),
            trailing: Text(
              entry.date.toLocal().toString().split(' ')[0],
              style: theme.textTheme.bodySmall,
            ),
            isThreeLine: entry.description != null,
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeItem(IncomeEntry entry, ThemeData theme) {
    return SlidableTransactionItem(
      key: ValueKey(entry.id),
      onTap: () => widget.onEdit(entry),
      onEdit: () => widget.onEdit(entry),
      onDelete: () => widget.onDelete(entry),
      onConfirm: entry.isPotential ? () => widget.onConfirm?.call(entry) : null,
      child: Opacity(
        opacity: entry.isPotential ? 0.7 : 1.0,
        child: Card(
          shape: entry.isPotential
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                )
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: entry.isPotential
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primaryContainer,
              child: Icon(
                entry.isPotential
                    ? Icons.help_outline
                    : Icons.arrow_downward,
                color: entry.isPotential
                    ? theme.colorScheme.outline
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Row(
              children: [
                Text(
                  CurrencyFormatter.format(
                    entry.amount,
                    currencyCode: widget.currencyCode,
                  ),
                ),
                if (entry.isPotential)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '(Potential)',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.categoryName != null)
                  Text(
                    'Category: ${entry.categoryName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                Text(entry.description ?? 'No description'),
              ],
            ),
            trailing: Text(
              entry.date.toLocal().toString().split(' ')[0],
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
  }
}
