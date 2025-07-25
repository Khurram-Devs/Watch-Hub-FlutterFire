import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrdersSkeleton extends StatelessWidget {
  final bool isWide;

  const OrdersSkeleton({super.key, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      itemCount: 4,
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 2 : 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isWide ? 2.5 : 1.6,
      ),
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surface,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 120, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 80, color: Colors.white),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Container(width: 80, height: 80, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 12,
                              width: 100,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 28, width: 100, color: Colors.white),
                ],
              ),
            ),
          ),
    );
  }
}
