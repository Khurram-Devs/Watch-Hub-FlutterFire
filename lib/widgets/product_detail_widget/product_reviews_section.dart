import 'package:flutter/material.dart';

class ProductReviewsSection extends StatelessWidget {
  final String productId;

  const ProductReviewsSection({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Reviews",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: const Text("Great quality and style!"),
          subtitle: const Text("Absolutely love this watch. Highly recommend!"),
        ),
        ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: const Text("Elegant timepiece"),
          subtitle: const Text("Perfect for gifting, looks very premium."),
        ),
      ],
    );
  }
}