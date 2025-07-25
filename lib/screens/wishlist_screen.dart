import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:watch_hub_ep/models/product_model.dart';
import 'package:watch_hub_ep/widgets/catalog_screen_widget/product_list_item.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/services/cart_service.dart';
import 'package:watch_hub_ep/widgets/skeleton_widget/wishlist_item_skeleton.dart';

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  final ProfileService _srv = ProfileService();
  final CartService _cartService = CartService();

  Future<List<ProductModel>> _fetchWishlistProducts(List<dynamic> refs) async {
    return await _srv.getProductsFromRefs(refs);
  }

  Future<void> _removeFromWishlist(String productId) async {
    await _srv.removeFromWishlist(productId);
  }

  Future<void> _addToCart(BuildContext context, ProductModel product) async {
    await _cartService.addProductToCart(product);
    await _removeFromWishlist(product.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product moved to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your wishlist.')),
      );
    }

    final usersProfile = FirebaseFirestore.instance.collection('usersProfile');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Wishlist',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: usersProfile.doc(uid).snapshots(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData) {
                      return ListView.builder(
                        itemCount: 3,
                        itemBuilder: (_, __) => const WishlistItemSkeleton(),
                      );
                    }

                    final data = userSnap.data!.data() as Map<String, dynamic>;
                    final List<dynamic> wishlistRefs = data['wishlist'] ?? [];

                    if (wishlistRefs.isEmpty) {
                      return const Center(
                        child: Text('No products in wishlist yet.'),
                      );
                    }

                    return FutureBuilder<List<ProductModel>>(
                      future: _fetchWishlistProducts(wishlistRefs),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return ListView.builder(
                            itemCount: 3,
                            itemBuilder:
                                (_, __) => const WishlistItemSkeleton(),
                          );
                        }

                        final products = snapshot.data!;
                        if (products.isEmpty) {
                          return const Center(
                            child: Text('No products found in wishlist.'),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 32),
                          itemCount: products.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 16),
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
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          label: const Text('Remove'),
                                          onPressed:
                                              () => _removeFromWishlist(
                                                product.id,
                                              ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.redAccent,
                                          ),
                                        ),
                                        if (product.stock > 0)
                                          ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.shopping_cart,
                                            ),
                                            label: const Text('Move to Cart'),
                                            onPressed:
                                                () => _addToCart(
                                                  context,
                                                  product,
                                                ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
