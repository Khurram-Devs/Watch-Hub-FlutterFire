import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TestimonialCarouselSkeleton extends StatelessWidget {
  const TestimonialCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceVariant,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          separatorBuilder: (_, __) => const SizedBox(width: 16),
        ),
      ),
    );
  }
}
