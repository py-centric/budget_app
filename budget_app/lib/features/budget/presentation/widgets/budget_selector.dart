import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget.dart';
import '../bloc/navigation_bloc.dart';

class BudgetSelector extends StatelessWidget {
  final List<Budget> budgets;
  final Budget activeBudget;

  const BudgetSelector({
    super.key,
    required this.budgets,
    required this.activeBudget,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.length <= 1) return const SizedBox.shrink();

    return DropdownButton<Budget>(
      value: activeBudget,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      selectedItemBuilder: (context) {
        return budgets.map((budget) {
          return Center(
            child: Text(
              budget.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      items: budgets.map((budget) {
        return DropdownMenuItem(
          value: budget,
          child: Text(budget.name),
        );
      }).toList(),
      onChanged: (budget) {
        if (budget != null && budget != activeBudget) {
          context.read<NavigationBloc>().add(ChangeBudget(budget));
        }
      },
    );
  }
}
