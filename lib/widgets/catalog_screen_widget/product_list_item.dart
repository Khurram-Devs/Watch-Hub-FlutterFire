import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../screens/product_detail_screen.dart';
import '../../theme/theme_provider.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;
  const ProductListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDiscounted =
        product.discountPercentage != null && product.discountPercentage! > 0;

    final discountedPrice = isDiscounted
        ? product.price * (1 - product.discountPercentage! / 100)
        : product.price;
final isOutOfStock = product.stock != null && product.stock! <= 0;
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        product.images.first,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    ),

    if (isDiscounted)
      Positioned(
        top: 6,
        left: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: ThemeProvider.goldenColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '-${product.discountPercentage!.toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.black),
          ),
        ),
      ),

    if (isOutOfStock)
      Positioned(
        top: 6,
        right: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Out of Stock',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ),
      ),
  ],
),


              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      product.brandName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        if (isDiscounted)
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        if (isDiscounted) const SizedBox(width: 6),
                        Text(
                          '\$${discountedPrice.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ThemeProvider.emeraldGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
