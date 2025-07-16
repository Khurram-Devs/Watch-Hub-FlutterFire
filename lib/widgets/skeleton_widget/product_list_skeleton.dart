import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
