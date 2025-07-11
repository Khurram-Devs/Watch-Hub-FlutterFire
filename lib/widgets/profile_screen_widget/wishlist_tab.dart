import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:watch_hub_ep/models/product_model.dart';
import 'package:watch_hub_ep/widgets/catalog_screen_widget/product_list_item.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/services/cart_service.dart';

class WishlistTab extends StatelessWidget {
  WishlistTab({super.key});

  final ProfileService _srv = ProfileService();
  final CartService _cartService = CartService();

  Future<List<ProductModel>> _fetchWishlistProducts(List<dynamic> refs) async {
    return await _srv.getProductsFromRefs(refs);
  }

  Future<void> _removeFromWishlist(String productId) async {
    await _srv.removeFromWishlist(productId);
  }

  Future<bool> isProductInCart(String productId) async {
    return await _cartService.isProductInCart(productId);
  }

  Future<void> addToCart(BuildContext context, ProductModel product) async {
    await _cartService.addProductToCart(product);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product moved to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final usersProfile = FirebaseFirestore.instance.collection('usersProfile');

    return FutureBuilder<DocumentSnapshot>(
      future: usersProfile.doc(uid).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = userSnap.data!.data() as Map<String, dynamic>;
        final List<dynamic> wishlistRefs = data['wishlist'] ?? [];

        if (wishlistRefs.isEmpty) {
          return const Center(child: Text('No products in wishlist yet.'));
        }

        return FutureBuilder<List<ProductModel>>(
          future: _fetchWishlistProducts(wishlistRefs),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!;
            if (products.isEmpty) {
              return const Center(
                child: Text('No products found in wishlist.'),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductListItem(product: product),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remove'),
                                  onPressed:
                                      () => _removeFromWishlist(product.id),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                  ),
                                ),
                                if (product.stock > 0)
                                  FutureBuilder<bool>(
                                    future: isProductInCart(product.id),
                                    builder: (context, snapshot) {
                                      final isInCart = snapshot.data ?? false;

                                      return ElevatedButton.icon(
                                        icon: Icon(
                                          isInCart
                                              ? Icons.check
                                              : Icons.shopping_cart,
                                        ),
                                        label: Text(
                                          isInCart
                                              ? 'Already in Cart'
                                              : 'Move to Cart',
                                        ),
                                        onPressed:
                                            isInCart
                                                ? null
                                                : () async {
                                                  await addToCart(
                                                    context,
                                                    product,
                                                  );
                                                  ;
                                                },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          backgroundColor:
                                              isInCart ? Colors.grey : null,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
