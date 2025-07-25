import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartSummarySkeleton extends StatelessWidget {
  const CartSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(4, (_) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
              );
            })..addAll([
              const SizedBox(height: 16),
              Container(
                height: 48,
                width: double.infinity,
                color: Colors.grey[300],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
