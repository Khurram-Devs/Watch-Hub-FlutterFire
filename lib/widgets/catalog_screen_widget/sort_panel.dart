import 'package:flutter/material.dart';
import '../../../models/sort_option.dart';

class SortPanel extends StatelessWidget {
  final SortOption current;
  final void Function(String) onSort;

  const SortPanel({super.key, required this.current, required this.onSort});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Text("Sort by:",  style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: current.value,
              isExpanded: true,
              onChanged: (val) {
                if (val != null) onSort(val);
              },
              items: [
                DropdownMenuItem(value: 'arrival', child: Text("Newest",  style: Theme.of(context).textTheme.bodySmall)),
                DropdownMenuItem(value: 'price_asc', child: Text("Price ↑",  style: Theme.of(context).textTheme.bodySmall)),
                DropdownMenuItem(value: 'price_desc', child: Text("Price ↓",  style: Theme.of(context).textTheme.bodySmall)),
                DropdownMenuItem(value: 'rating', child: Text("Rating",  style: Theme.of(context).textTheme.bodySmall)),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
