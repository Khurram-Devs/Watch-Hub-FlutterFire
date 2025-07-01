import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _productsRef = FirebaseFirestore.instance.collection('products');

  Future<List<ProductModel>> getNewArrivals() async {
    final snapshot = await _productsRef
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    return Future.wait(snapshot.docs.map((doc) =>
        ProductModel.fromFirestoreWithBrand(doc.data(), doc.id)));
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final snapshot = await _productsRef
        .orderBy('averageRating', descending: true)
        .limit(10)
        .get();

    return Future.wait(snapshot.docs.map((doc) =>
        ProductModel.fromFirestoreWithBrand(doc.data(), doc.id)));
  }

  Future<List<ProductModel>> loadDiscountedProducts() async {
  final snapshot = await _productsRef
      .where('discountPercentage', isGreaterThan: 0)
      .orderBy('discountPercentage', descending: true)
      .limit(4)
      .get();

  return Future.wait(snapshot.docs.map(
    (doc) => ProductModel.fromFirestoreWithBrand(doc.data(), doc.id),
  ));
}

Future<List<ProductModel>> getRelatedProducts(String brandName, String excludeProductId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('products')
      .where('brandName', isEqualTo: brandName)
      .get();

  final all = await Future.wait(snapshot.docs.map((doc) async {
    final product = await ProductModel.fromFirestoreWithBrand(doc.data(), doc.id);
    return product;
  }));

  return all.where((p) => p.id != excludeProductId).toList();
}


}
