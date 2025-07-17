import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/sort_option.dart';

class ProductService {
  final _productsRef = FirebaseFirestore.instance.collection('products');

  Future<List<ProductModel>> getNewArrivals() async {
    final snapshot =
        await _productsRef
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

    return Future.wait(
      snapshot.docs.map(
        (doc) => ProductModel.fromFirestoreWithBrand(doc.data(), doc.id),
      ),
    );
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final snapshot =
        await _productsRef
            .orderBy('averageRating', descending: true)
            .limit(10)
            .get();

    return Future.wait(
      snapshot.docs.map(
        (doc) => ProductModel.fromFirestoreWithBrand(doc.data(), doc.id),
      ),
    );
  }

  Future<List<ProductModel>> loadDiscountedProducts() async {
    final snapshot =
        await _productsRef
            .where('discountPercentage', isGreaterThan: 0)
            .orderBy('discountPercentage', descending: true)
            .limit(4)
            .get();

    return Future.wait(
      snapshot.docs.map(
        (doc) => ProductModel.fromFirestoreWithBrand(doc.data(), doc.id),
      ),
    );
  }

  Future<List<ProductModel>> getRelatedProducts(
    String brandName,
    String excludeProductId,
  ) async {
    final brandSnapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            .where('name', isEqualTo: brandName)
            .limit(1)
            .get();

    if (brandSnapshot.docs.isEmpty) {
      return [];
    }

    final DocumentReference brandRef = brandSnapshot.docs.first.reference;

    final snapshot =
        await _productsRef.where('brand', isEqualTo: brandRef).get();

    final all = await Future.wait(
      snapshot.docs.map((doc) async {
        final product = await ProductModel.fromFirestoreWithBrand(
          doc.data(),
          doc.id,
        );
        return product..firestoreSnapshot = doc;
      }),
    );

    return all.where((p) => p.id != excludeProductId).toList();
  }

  Future<List<ProductModel>> fetchCatalog({
    required int page,
    required int limit,
    required SortOption sort,
    String? brand,
    double? minPrice,
    double? maxPrice,
    DocumentSnapshot? lastDoc,
    List<String>? categories,
    bool? inStock,
    bool? discountedOnly,
    double? minRating,
  }) async {
    Query<Map<String, dynamic>> q = _productsRef;

if (brand != null && brand.isNotEmpty) {
  // Fetch the brand document from 'categories' collection by name
  final brandQuerySnapshot = await FirebaseFirestore.instance
      .collection('categories')
      .where('name', isEqualTo: brand)
      .limit(1)
      .get();

  if (brandQuerySnapshot.docs.isEmpty) {
    // No brand found, return empty list or skip brand filter
    return [];
  }

  final brandRef = brandQuerySnapshot.docs.first.reference;
  q = q.where('brand', isEqualTo: brandRef);
}


    if (categories != null && categories.isNotEmpty) {
      final categoryRefs =
          categories
              .map(
                (id) =>
                    FirebaseFirestore.instance.collection('categories').doc(id),
              )
              .toList();
      q = q.where('categories', arrayContainsAny: categoryRefs);
    }

    if (inStock == true) {
      q = q.where('inventoryCount', isGreaterThan: 0);
    }

    if (discountedOnly == true) {
      q = q.where('discountPercentage', isGreaterThan: 0);
    }

    if (minRating != null) {
      q = q.where('averageRating', isGreaterThanOrEqualTo: minRating);
    }

    if (minPrice != null || maxPrice != null) {
      q = q.orderBy('price');
      if (minPrice != null) {
        q = q.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        q = q.where('price', isLessThanOrEqualTo: maxPrice);
      }
    } else {
      switch (sort) {
        case SortOption.PriceAsc:
          q = q.orderBy('price');
          break;
        case SortOption.PriceDesc:
          q = q.orderBy('price', descending: true);
          break;
        case SortOption.Rating:
          q = q.orderBy('averageRating', descending: true);
          break;
        case SortOption.New:
        default:
          q = q.orderBy('createdAt', descending: true);
      }
    }

    if (lastDoc != null) {
      q = q.startAfterDocument(lastDoc);
    }

    final snapshot = await q.limit(limit).get();

    return Future.wait(
      snapshot.docs.map((doc) async {
        final product = await ProductModel.fromFirestoreWithBrand(
          doc.data(),
          doc.id,
        );
        product.firestoreSnapshot = doc;
        return product;
      }),
    );
  }
}
