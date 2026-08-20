import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import 'pycentric_about_dialog.dart';

class PyCentricFooterWidget extends StatelessWidget {
  final bool compact;
  final VoidCallback? onTap;

  const PyCentricFooterWidget({
    super.key,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.xs : AppSpacing.sm,
        horizontal: AppSpacing.sm,
      ),
      child: Semantics(
        button: true,
        label: 'Developed by PyCentric. Tap to view about dialog.',
        child: InkWell(
          onTap: onTap ?? () => PyCentricAboutDialog.show(context),
          borderRadius: BorderRadius.circular(4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: Text(
                'Developed by PyCentric',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: compact ? 10 : 11,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
