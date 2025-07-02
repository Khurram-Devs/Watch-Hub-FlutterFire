import 'package:flutter/material.dart';

class ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onToggle;
  const ViewToggle({super.key, required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.grid_view,
            color: isGrid ? Theme.of(context).colorScheme.secondary : null,
          ),
          onPressed: () => onToggle(true),
        ),
        IconButton(
          icon: Icon(
            Icons.view_list,
            color: isGrid ? null : Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () => onToggle(false),
        ),
      ],
    );
  }
}
