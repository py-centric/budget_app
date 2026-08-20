import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_config.dart';

class DashboardSettingsPage extends StatefulWidget {
  const DashboardSettingsPage({super.key});

  @override
  State<DashboardSettingsPage> createState() => _DashboardSettingsPageState();
}

class _DashboardSettingsPageState extends State<DashboardSettingsPage> {
  final DashboardConfig _config = DashboardConfig.defaultConfig();

  static const Map<String, String> _widgetLabels = {
    'net_worth': 'Net Worth',
    'recent_transactions': 'Recent Transactions',
    'budget_overview': 'Budget Overview',
    'upcoming_bills': 'Upcoming Bills',
    'spending_chart': 'Spending Chart',
    'savings_goals': 'Savings Goals',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Settings'),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _config.widgetOrder.length,
        onReorderItem: (oldIndex, newIndex) {
          setState(() {
            final item = _config.widgetOrder.removeAt(oldIndex);
            _config.widgetOrder.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final widgetId = _config.widgetOrder[index];
          final isVisible = _config.visibility[widgetId] ?? true;
          return Card(
            key: ValueKey(widgetId),
            child: ListTile(
              leading: const Icon(Icons.drag_handle),
              title: Text(_widgetLabels[widgetId] ?? widgetId),
              trailing: Switch(
                value: isVisible,
                onChanged: (val) {
                  setState(() {
                    _config.visibility[widgetId] = val;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
