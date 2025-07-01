import 'package:flutter/material.dart';

class ProductSpecs extends StatelessWidget {
  final Map<String, dynamic> specs;

  const ProductSpecs({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Specifications",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        ...specs.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: theme.textTheme.bodyMedium),
                  Text(
                    e.value.toString(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
