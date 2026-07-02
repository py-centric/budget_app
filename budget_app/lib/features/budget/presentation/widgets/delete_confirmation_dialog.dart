import 'package:flutter/material.dart';
import 'package:budget_app/shared/widgets/confirm_action_dialog.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmActionDialog(
      title: title,
      message: content,
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: onConfirm,
    );
  }
}
