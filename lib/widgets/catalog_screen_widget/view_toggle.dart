import 'package:flutter/material.dart';

class ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onToggle;

  const ViewToggle({super.key, required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.grid_view,
              color: isGrid ? secondary : theme.iconTheme.color?.withOpacity(0.6),
            ),
            tooltip: "Grid View",
            onPressed: () => onToggle(true),
          ),
          IconButton(
            icon: Icon(
              Icons.view_list,
              color: !isGrid ? secondary : theme.iconTheme.color?.withOpacity(0.6),
            ),
            tooltip: "List View",
            onPressed: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}
