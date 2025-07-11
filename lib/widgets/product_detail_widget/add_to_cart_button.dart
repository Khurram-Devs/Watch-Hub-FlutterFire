import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub_ep/screens/user/auth_screen.dart';
import '../../../models/product_model.dart';

class AddToCartButton extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onPressed;

  const AddToCartButton({super.key, required this.product, this.onPressed});

  void _handlePress(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add items to cart.")),
      );
      context.push('/auth');
      return;
    }

    if (onPressed != null) {
      onPressed!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.title} added to cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: () => _handlePress(context),
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
