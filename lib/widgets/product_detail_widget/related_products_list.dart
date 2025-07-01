import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../home_screen_widget/collection_card.dart';

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
              height: 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  return CollectionCard(product: p);
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
