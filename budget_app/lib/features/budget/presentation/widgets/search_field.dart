import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const SearchField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search by description...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(
        text: initialValue,
      )..selection = TextSelection.collapsed(offset: initialValue?.length ?? 0),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: initialValue != null && initialValue!.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
                tooltip: 'Clear search',
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}
