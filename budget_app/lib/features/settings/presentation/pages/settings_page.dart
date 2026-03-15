import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
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
                          DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar (\$)')),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro (€)')),
                          DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound (£)')),
                          DropdownMenuItem(value: 'JPY', child: Text('JPY - Japanese Yen (¥)')),
                          DropdownMenuItem(value: 'CAD', child: Text('CAD - Canadian Dollar (\$)')),
                          DropdownMenuItem(value: 'AUD', child: Text('AUD - Australian Dollar (\$)')),
                          DropdownMenuItem(value: 'CNY', child: Text('CNY - Chinese Yuan (¥)')),
                          DropdownMenuItem(value: 'INR', child: Text('INR - Indian Rupee (₹)')),
                          DropdownMenuItem(value: 'BRL', child: Text('BRL - Brazilian Real (R\$)')),
                          DropdownMenuItem(value: 'PLN', child: Text('PLN - Polish Złoty (zł)')),
                          DropdownMenuItem(value: 'ZAR', child: Text('ZAR - South African Rand (R)')),
                          DropdownMenuItem(value: 'NGN', child: Text('NGN - Nigerian Naira (₦)')),
                          DropdownMenuItem(value: 'EGP', child: Text('EGP - Egyptian Pound (E£)')),
                          DropdownMenuItem(value: 'KES', child: Text('KES - Kenyan Shilling (KSh)')),
                          DropdownMenuItem(value: 'GHS', child: Text('GHS - Ghanaian Cedi (GH₵)')),
                          DropdownMenuItem(value: 'MAD', child: Text('MAD - Moroccan Dirham (MAD)')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(UpdateCurrencyEvent(value));
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
                          DropdownMenuItem(value: 'system', child: Text('System Default')),
                          DropdownMenuItem(value: 'light', child: Text('Light')),
                          DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(UpdateThemeEvent(value));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
