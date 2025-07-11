import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/add_to_wishlist_button.dart';

class CollectionCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onViewTap;

  const CollectionCard({
    super.key,
    required this.product,
    this.onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 220,
      constraints: const BoxConstraints(minHeight: 340),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ░░ Image with Wishlist Icon ░░
          Container(
            height: 150,
            padding: const EdgeInsets.all(6),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.disabledColor.withOpacity(0.1),
                        alignment: Alignment.center,
                        child: Icon(Icons.watch, color: theme.colorScheme.secondary),
                      ),
                    ),
                  ),
                ),

                // ✅ AddToWishlistButton placed here
                Positioned(
                  top: 8,
                  right: 8,
                  child: AddToWishlistButton(product: product),
                ),
              ],
            ),
          ),

          // ░░ Product Info ░░
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  product.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 16,
                          color: theme.colorScheme.secondary.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: ' ${product.price.toStringAsFixed(0)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewTap ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    child: const Text("View"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
