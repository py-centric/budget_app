import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import 'pycentric_about_dialog.dart';

class BrandingFooter extends StatelessWidget {
  const BrandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Semantics(
          button: true,
          label: 'Developed by PyCentric. Tap to view about dialog.',
          child: InkWell(
            onTap: () => PyCentricAboutDialog.show(context),
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                ),
                child: Text(
                  'Developed by PyCentric',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
