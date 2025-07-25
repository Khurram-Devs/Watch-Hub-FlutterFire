import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub_ep/services/cart_service.dart';
import '../../../models/product_model.dart';

class AddToCartButton extends StatefulWidget {
  final ProductModel product;

  const AddToCartButton({super.key, required this.product});

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool isInCart = false;
  bool loading = false;

  bool get isOutOfStock => (widget.product.stock ?? 0) <= 0;

  @override
  void initState() {
    super.initState();
    _checkIfInCart();
  }

  Future<void> _checkIfInCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final exists = await CartService().isInCart(widget.product.id);
    setState(() {
      isInCart = exists;
    });
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add items to cart.")),
      );
      context.push('/auth/login');
      return;
    }

    if (isOutOfStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This product is out of stock.")),
      );
      return;
    }

    setState(() => loading = true);

    if (!isInCart) {
      await CartService().addToCart(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.title} added to cart!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.title} is already in cart!')),
      );
    }

    await _checkIfInCart();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = loading || isOutOfStock;

    return ElevatedButton.icon(
      onPressed: isDisabled ? null : () => _handleAddToCart(context),
      icon: Icon(
        isOutOfStock
            ? Icons.block
            : isInCart
            ? Icons.check_circle
            : Icons.add_shopping_cart,
      ),
      label: Text(
        isOutOfStock
            ? "Out of Stock"
            : isInCart
            ? "Already in Cart"
            : "Add to Cart",
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
