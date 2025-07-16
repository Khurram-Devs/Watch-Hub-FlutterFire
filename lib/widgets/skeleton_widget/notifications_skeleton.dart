import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: colorScheme.surfaceVariant,
          highlightColor: colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading Icon Placeholder
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // Notification Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + dot row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 14,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Message text line
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),

                      // Time text line
                      Container(
                        height: 10,
                        width: 60,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
