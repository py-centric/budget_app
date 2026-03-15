import 'package:flutter/material.dart';

class YearGroupHeader extends StatelessWidget {
  final int year;
  final bool isExpanded;
  final VoidCallback onTap;

  const YearGroupHeader({
    super.key,
    required this.year,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        year.toString(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
      ),
      onTap: onTap,
    );
  }
}
