import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BrandsScrollerSkeleton extends StatelessWidget {
  const BrandsScrollerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder:
              (_, __) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
        ),
      ),
    );
  }
}
