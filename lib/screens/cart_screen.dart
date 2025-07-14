import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub_ep/models/product_model.dart';
import 'package:watch_hub_ep/services/cart_service.dart';
import 'package:watch_hub_ep/widgets/cart_screen_widget/cart_item_tile.dart';
import 'package:watch_hub_ep/widgets/cart_screen_widget/cart_summary.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<Map<String, dynamic>>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    _cartFuture = CartService().fetchCartItemsWithQuantity();
  }

  void _refreshCart() {
    setState(() {
      _loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Cart content
          
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cartFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 60),
                      const Icon(Icons.shopping_cart_outlined, size: 64),
                      const SizedBox(height: 16),
                      const Text("No items in cart", style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/catalog'),
                        child: const Text("Add Products"),
                      ),
                    ],
                  );
                }

                final cartItems = snapshot.data!;
                final isWide = MediaQuery.of(context).size.width > 700;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: cartItems.map((item) {
                                  final product = item['product'] as ProductModel;
                                  final quantity = item['quantity'] as int;
                                  return CartItemTile(
                                    product: product,
                                    quantity: quantity,
                                    onChanged: _refreshCart,
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 32),
                            const Expanded(
                              flex: 1,
                              child: CartSummary(),
                            ),
                          ],
                        )
                      else ...[
                        ...cartItems.map((item) => CartItemTile(
                              product: item['product'],
                              quantity: item['quantity'],
                              onChanged: _refreshCart,
                            )),
                        const SizedBox(height: 24),
                        const CartSummary(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          ),
      );
  }
}
