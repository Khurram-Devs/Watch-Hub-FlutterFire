import 'package:flutter/material.dart';
import '../../../models/sort_option.dart';

class SortPanel extends StatelessWidget {
  final SortOption current;
  final void Function(String) onSort;

  const SortPanel({super.key, required this.current, required this.onSort});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildButton(String label, String value) {
      final isSelected = current.value == value;
      return GestureDetector(
        onTap: () => onSort(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                    : theme.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color:
                  isSelected
                      ? theme.colorScheme.secondary
                      : theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text("Sort:", style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildButton("Newest", 'arrival'),
                  buildButton("Price ↑", 'price_asc'),
                  buildButton("Price ↓", 'price_desc'),
                  buildButton("Rating", 'rating'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
