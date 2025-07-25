import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watch_hub_ep/models/product_model.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/image_gallery.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_info.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_specs.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/add_to_cart_button.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/add_to_wishlist_button.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/related_products_list.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_faq.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_reviews_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? product;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .get();
      final model = await ProductModel.fromDoc(doc);
      setState(() {
        product = model;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError || product == null
                ? const Center(child: Text('Failed to load product.'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImageGallery(images: product!.images),
                      const SizedBox(height: 24),
                      ProductInfo(product: product!),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: AddToCartButton(product: product!)),
                          const SizedBox(width: 12),
                          AddToWishlistButton(
                            product: product!,
                            productId: product!.id,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ProductSpecs(specs: product!.specs),
                      const SizedBox(height: 32),
                      RelatedProductsList(
                        brandName: product!.brandName,
                        currentProductId: product!.id,
                      ),
                      const SizedBox(height: 32),
                      const ProductFAQ(),
                      const SizedBox(height: 32),
                      ProductReviewsSection(productId: product!.id),
                    ],
                  ),
                ),
      ),
    );
  }
}
