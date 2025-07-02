import 'package:flutter/material.dart';

class ProductSpecs extends StatelessWidget {
  final String specs;

  const ProductSpecs({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specsList = specs.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...specsList.map(
          (line) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.check, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(line.trim(), style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
