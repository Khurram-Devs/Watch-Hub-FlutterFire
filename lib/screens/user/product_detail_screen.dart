import 'package:flutter/material.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';
import 'package:watch_hub_ep/widgets/layout_widget/footer_widget.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/image_gallery.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_info.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_specs.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/add_to_cart_button.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/add_to_wishlist_button.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/related_products_list.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_faq.dart';
import 'package:watch_hub_ep/widgets/product_detail_widget/product_reviews_section.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const NavDrawer(),
      appBar: const AppHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              ImageGallery(images: product.images),
              const SizedBox(height: 24),

              ProductInfo(product: product),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: AddToCartButton(product: product)),
                  const SizedBox(width: 12),
                  Expanded(child: AddToWishlistButton(product: product)),
                ],
              ),

              const SizedBox(height: 32),

              ProductSpecs(specs: product.specs),
              const SizedBox(height: 32),

              RelatedProductsList(
                brandName: product.brandName,
                currentProductId: product.id,
              ),

              const SizedBox(height: 32),

              const ProductFAQ(),

              const SizedBox(height: 32),

              ProductReviewsSection(productId: product.id),

              const SizedBox(height: 32),
              const FooterWidget(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
