import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../app_lock/data/repositories/app_lock_repository_impl.dart';
import '../../../app_lock/domain/entities/app_lock_settings.dart';
import '../../../app_lock/presentation/bloc/app_lock_bloc.dart';
import '../../../app_lock/presentation/bloc/app_lock_event.dart';
import '../../../app_lock/presentation/bloc/app_lock_state.dart';
import '../../../app_lock/presentation/widgets/lock_setup_dialog.dart';
import '../../../backup/data/services/backup_service_impl.dart';
import '../../../backup/presentation/bloc/backup_bloc.dart';
import '../../../backup/presentation/bloc/backup_event.dart';
import '../../../backup/presentation/bloc/backup_state.dart';
import '../../../budget/presentation/budget_bloc.dart';
import '../../../budget/presentation/budget_event.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Currency',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select your preferred currency for formatting values.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: state.settings.currencyCode,
                        decoration: const InputDecoration(
                          labelText: 'Currency Code',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'USD',
                            child: Text('USD - US Dollar (\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'EUR',
                            child: Text('EUR - Euro (€)'),
                          ),
                          DropdownMenuItem(
                            value: 'GBP',
                            child: Text('GBP - British Pound (£)'),
                          ),
                          DropdownMenuItem(
                            value: 'JPY',
                            child: Text('JPY - Japanese Yen (¥)'),
                          ),
                          DropdownMenuItem(
                            value: 'CAD',
                            child: Text('CAD - Canadian Dollar (\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'AUD',
                            child: Text('AUD - Australian Dollar (\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'CNY',
                            child: Text('CNY - Chinese Yuan (¥)'),
                          ),
                          DropdownMenuItem(
                            value: 'INR',
                            child: Text('INR - Indian Rupee (₹)'),
                          ),
                          DropdownMenuItem(
                            value: 'BRL',
                            child: Text('BRL - Brazilian Real (R\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'PLN',
                            child: Text('PLN - Polish Złoty (zł)'),
                          ),
                          DropdownMenuItem(
                            value: 'ZAR',
                            child: Text('ZAR - South African Rand (R)'),
                          ),
                          DropdownMenuItem(
                            value: 'NGN',
                            child: Text('NGN - Nigerian Naira (₦)'),
                          ),
                          DropdownMenuItem(
                            value: 'EGP',
                            child: Text('EGP - Egyptian Pound (E£)'),
                          ),
                          DropdownMenuItem(
                            value: 'KES',
                            child: Text('KES - Kenyan Shilling (KSh)'),
                          ),
                          DropdownMenuItem(
                            value: 'GHS',
                            child: Text('GHS - Ghanaian Cedi (GH₵)'),
                          ),
                          DropdownMenuItem(
                            value: 'MAD',
                            child: Text('MAD - Moroccan Dirham (MAD)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                              UpdateCurrencyEvent(value),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose between Light, Dark, or System Default themes.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: state.settings.themeMode,
                        decoration: const InputDecoration(
                          labelText: 'Theme Mode',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'system',
                            child: Text('System Default'),
                          ),
                          DropdownMenuItem(
                            value: 'light',
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                              UpdateThemeEvent(value),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocProvider(
                create: (context) =>
                    AppLockBloc(
                        repository: AppLockRepository(
                          authService: AuthServiceImpl(),
                        ),
                      )
                      ..add(AppLockLoadSettings())
                      ..add(AppLockCheckBiometricAvailability()),
                child: const _AppLockSection(),
              ),
              const SizedBox(height: 16),
              BlocProvider(
                create: (context) =>
                    BackupBloc(backupService: BackupServiceImpl()),
                child: const _BackupSection(),
              ),
              const SizedBox(height: 16),
              BlocProvider.value(
                value: context.read<BudgetBloc>(),
                child: const _FactoryResetSection(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppLockSection extends StatelessWidget {
  const _AppLockSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockBloc, AppLockState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'App Lock',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Switch(
                      value: state.settings.isEnabled,
                      onChanged: (value) {
                        if (value) {
                          _showEnableDialog(context, state);
                        } else {
                          _showDisableDialog(context);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.settings.isEnabled
                      ? 'App is locked with ${state.settings.authMethod == AuthMethod.biometrics ? "biometrics" : "PIN"}'
                      : 'Require authentication to open the app',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (state.settings.isEnabled) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap to ${state.settings.authMethod == AuthMethod.biometrics ? "change to PIN" : "change to biometrics"}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEnableDialog(BuildContext context, AppLockState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => LockSetupDialog(
        isBiometricAvailable: state.isBiometricAvailable,
        onComplete: (method, pin) {
          context.read<AppLockBloc>().add(
            AppLockEnable(method: method, pin: pin),
          );
        },
      ),
    );
  }

  void _showDisableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disable App Lock'),
        content: const Text('Enter your PIN to disable app lock:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackupBloc, BackupState>(
      listener: (context, state) {
        if (state.hasError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state.isSuccess && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Database Backup',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a backup of your database or restore from a backup file.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                context.read<BackupBloc>().add(BackupExport());
                              },
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.backup),
                        label: const Text('Backup'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => _selectAndImport(context),
                        icon: const Icon(Icons.restore),
                        label: const Text('Restore'),
                      ),
                    ),
                  ],
                ),
                if (state.filePath != null && state.isSuccess) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      context.read<BackupBloc>().add(
                        BackupShare(filePath: state.filePath!),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Backup'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectAndImport(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.single.path != null) {
        if (context.mounted) {
          context.read<BackupBloc>().add(
            BackupImport(filePath: result.files.single.path!),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _FactoryResetSection extends StatelessWidget {
  const _FactoryResetSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Factory Reset',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Delete all budgets and reset the app to its initial state. This cannot be undone.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showFactoryResetDialog(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Factory Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFactoryResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Factory Reset'),
        content: const Text(
          'Are you sure you want to delete all budgets and reset the app? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BudgetBloc>().add(FactoryResetEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Factory reset complete'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
