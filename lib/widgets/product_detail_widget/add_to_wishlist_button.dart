import 'package:flutter/material.dart';
import '../../../models/product_model.dart';

class AddToWishlistButton extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const AddToWishlistButton({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(Icons.favorite_border, color: theme.colorScheme.secondary),
      onPressed: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.title} added to wishlist')),
        );
      },
    );
  }
}