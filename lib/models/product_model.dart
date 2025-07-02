import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> images;
  final double price;
  final double averageRating;
  final double discountPercentage;
  final int stock;
  final DateTime createdAt;
  final String brandName;
  final Map<String, dynamic> specs; // ✅ FIXED: specs now Map type

  DocumentSnapshot? firestoreSnapshot;

  ProductModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.images,
    required this.price,
    required this.averageRating,
    required this.discountPercentage,
    required this.stock,
    required this.createdAt,
    required this.brandName,
    required this.specs,
    this.firestoreSnapshot,
  });

  static Future<ProductModel> fromFirestoreWithBrand(
    Map<String, dynamic> data,
    String id,
  ) async {
    final brandRef = data['brand'] as DocumentReference;
    final brandSnap = await brandRef.get();
    final brandData = brandSnap.data() as Map<String, dynamic>;
    final brandName = brandData['name'];

    return ProductModel(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      specs: Map<String, dynamic>.from(data['specs'] ?? {}), // ✅ FIXED
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0).toDouble(),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      stock: data['inventoryCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      brandName: brandName,
    );
  }
}
