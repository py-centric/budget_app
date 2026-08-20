import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableTransactionItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onConfirm;
  final VoidCallback? onTap;
  final bool isIncome;

  const SlidableTransactionItem({
    super.key,
    required this.child,
    required this.onEdit,
    required this.onDelete,
    this.onConfirm,
    this.onTap,
    this.isIncome = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmLabel = isIncome ? 'Mark as Received' : 'Mark as Paid';

    final Map<CustomSemanticsAction, VoidCallback> actions = {
      const CustomSemanticsAction(label: 'Edit'): onEdit,
      const CustomSemanticsAction(label: 'Delete'): onDelete,
    };
    if (onConfirm != null) {
      actions[CustomSemanticsAction(label: confirmLabel)] = onConfirm!;
    }

    return Semantics(
      customSemanticsActions: actions,
      child: Slidable(
        key: key,
        startActionPane: onConfirm != null
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => onConfirm!(),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    icon: isIncome ? Icons.check_circle : Icons.payments,
                    label: isIncome ? 'Received' : 'Paid',
                  ),
                ],
              )
            : null,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: onTap != null ? InkWell(onTap: onTap, child: child) : child,
      ),
    );
  }
}
