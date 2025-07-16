import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WishlistItemSkeleton extends StatelessWidget {
  const WishlistItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, width: double.infinity, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(height: 16, width: 150, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(height: 160, width: 100, color: Colors.grey[300]),
                        const SizedBox(width: 12),
                        Container(height: 160, width: 120, color: Colors.grey[300]),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
