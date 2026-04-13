import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableTransactionItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onConfirm;
  final VoidCallback? onTap;

  const SlidableTransactionItem({
    super.key,
    required this.child,
    required this.onEdit,
    required this.onDelete,
    this.onConfirm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key,
      startActionPane: onConfirm != null
          ? ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => onConfirm!(),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_outline,
                  label: 'Confirm',
                ),
              ],
            )
          : null,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: onTap != null ? InkWell(onTap: onTap, child: child) : child,
    );
  }
}
