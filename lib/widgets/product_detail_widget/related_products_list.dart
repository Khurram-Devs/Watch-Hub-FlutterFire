import 'package:flutter/material.dart';
import 'package:watch_hub_ep/widgets/catalog_screen_widget/product_grid_item.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class RelatedProductsList extends StatelessWidget {
  final String brandName;
  final String currentProductId;

  const RelatedProductsList({
    super.key,
    required this.brandName,
    required this.currentProductId,
  });

  @override
  Widget build(BuildContext context) {
    final service = ProductService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You may also like',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<ProductModel>>(
          future: service.getRelatedProducts(brandName, currentProductId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Text('Error loading related products.');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No related products found.');
            }

            final products = snapshot.data!;

            return SizedBox(
              height: 380,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (_, i) {
                  return ProductGridItem(product: products[i]);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 16),
              ),
            );
          },
        ),
      ],
    );
  }
}
