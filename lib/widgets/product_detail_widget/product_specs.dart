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
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 16),

        ...specs.entries.map((e) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      e.key,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      e.value.toString(),
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (e != specs.entries.last) ...[
                const SizedBox(height: 8),
                Divider(
                  color: Colors.grey.withValues(alpha: 0.3),
                  thickness: 0.7,
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        }),
      ],
    );
  }
}
