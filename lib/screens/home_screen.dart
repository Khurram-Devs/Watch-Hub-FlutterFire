import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/testimonial_service.dart';
import 'package:watch_hub_ep/widgets/home_screen_widget/search_bar_widget.dart';
import 'package:watch_hub_ep/widgets/home_screen_widget/testimonial_widget.dart';
import '../widgets/layout_widget/section_title.dart';
import '../widgets/home_screen_widget/single_video_banner.dart';
import '../widgets/home_screen_widget/infinite_brands_scroller.dart';
import '../widgets/home_screen_widget/contact_us_form.dart';
import 'package:watch_hub_ep/widgets/catalog_screen_widget/product_grid_item.dart';
import 'package:watch_hub_ep/widgets/catalog_screen_widget/product_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _productService = ProductService();
  final _testimonialService = TestimonialService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SearchBarWidget(controller: _searchController),
              const SizedBox(height: 12),

              const SingleVideoBanner(
                videoUrl:
                    'https://media.rolex.com/video/upload/c_limit,w_2880/f_auto:video/q_auto:eco/v1/rolexcom/new-watches/2025/hub/videos/autoplay/cover/rolex-watches-new-watches-2025-cover-autoplay',
              ),
              const SizedBox(height: 32),

              SectionTitle(
                title: 'New Arrivals',
                action: 'See all',
                onActionTap: () {
                  context.push('/catalog');
                },
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<ProductModel>>(
                future: _productService.getNewArrivals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading products');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No products found');
                  }

                  final products = snapshot.data!;

                  return SizedBox(
                    height: 380,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];
                        return ProductGridItem(product: product);
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const SectionTitle(title: 'Premium Discounts'),
              const SizedBox(height: 12),

              FutureBuilder<List<ProductModel>>(
                future: _productService.loadDiscountedProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No discounted products found.");
                  }

                  return Column(
                    children: snapshot.data!.map((product) {
                      return ProductListItem(product: product);
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 32),
              const SectionTitle(title: 'Our Brands'),
              const SizedBox(height: 12),
              const InfiniteBrandsScroller(),

              const SizedBox(height: 32),
              SectionTitle(
                title: 'Featured',
                action: 'See all',
                onActionTap: () => context.push('/catalog'),
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<ProductModel>>(
                future: _productService.getFeaturedProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading products');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No products found');
                  }

                  final products = snapshot.data!;

                  return SizedBox(
                    height: 380,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];
                        return ProductGridItem(product: product);
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              const TestimonialCarousel(),

              const SizedBox(height: 32),
              ContactUsForm(),
            ],
          ),
        ),
      ),
    );
  }
}
