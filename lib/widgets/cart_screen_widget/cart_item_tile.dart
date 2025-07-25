import 'package:flutter/material.dart';
import 'package:watch_hub_ep/models/product_model.dart';
import 'package:watch_hub_ep/widgets/catalog_screen_widget/product_list_item.dart';
import 'package:watch_hub_ep/services/cart_service.dart';

class CartItemTile extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onChanged;

  const CartItemTile({
    super.key,
    required this.product,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ProductListItem(product: product),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed:
                            quantity > 1
                                ? () async {
                                  await CartService().updateQuantity(
                                    product.id,
                                    quantity - 1,
                                  );
                                  onChanged();
                                }
                                : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$quantity'),
                      IconButton(
                        onPressed:
                            quantity < (product.stock ?? 1)
                                ? () async {
                                  await CartService().updateQuantity(
                                    product.id,
                                    quantity + 1,
                                  );
                                  onChanged();
                                }
                                : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      await CartService().removeFromCart(product.id);
                      onChanged();
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ],
    );
  }
}
