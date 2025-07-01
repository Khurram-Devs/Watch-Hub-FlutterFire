import 'package:flutter/material.dart';
import '../../../models/product_model.dart';

class AddToCartButton extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onPressed;

  const AddToCartButton({
    super.key,
    required this.product,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.title} added to cart!')),
        );
      },
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text("Add to Cart"),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}