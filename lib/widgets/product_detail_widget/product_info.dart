import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductInfo extends StatelessWidget {
  final ProductModel product;

  const ProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.brandName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.description,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (product.discountPercentage > 0)
              Text(
                "\$${product.price.toStringAsFixed(2)}",
                style: theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(width: 8),
            Text(
              "\$${(product.price * (1 - product.discountPercentage / 100)).toStringAsFixed(2)}",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
