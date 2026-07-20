import 'package:equatable/equatable.dart';

class DashboardConfig extends Equatable {
  final List<String> widgetOrder;
  final Map<String, bool> visibility;

  const DashboardConfig({
    required this.widgetOrder,
    required this.visibility,
  });

  factory DashboardConfig.defaultConfig() {
    return const DashboardConfig(
      widgetOrder: [
        'net_worth',
        'recent_transactions',
        'budget_overview',
        'upcoming_bills',
        'spending_chart',
        'savings_goals',
      ],
      visibility: {
        'net_worth': true,
        'recent_transactions': true,
        'budget_overview': true,
        'upcoming_bills': true,
        'spending_chart': true,
        'savings_goals': true,
      },
    );
  }

  factory DashboardConfig.fromMap(Map<String, dynamic> map) {
    return DashboardConfig(
      widgetOrder: List<String>.from(map['widget_order'] as List<dynamic>? ?? []),
      visibility: Map<String, bool>.from(map['visibility'] as Map<dynamic, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'widget_order': widgetOrder,
      'visibility': visibility,
    };
  }

  DashboardConfig copyWith({
    List<String>? widgetOrder,
    Map<String, bool>? visibility,
  }) {
    return DashboardConfig(
      widgetOrder: widgetOrder ?? this.widgetOrder,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  List<Object?> get props => [widgetOrder, visibility];
}
