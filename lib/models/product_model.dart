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
  final DateTime createdAt;
  final String brandName;
  final Map<String, dynamic> specs; // 👈 NEW

  ProductModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.images,
    required this.price,
    required this.averageRating,
    required this.discountPercentage,
    required this.createdAt,
    required this.brandName,
    required this.specs, // 👈 NEW
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
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0).toDouble(),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      brandName: brandName,
      specs: Map<String, dynamic>.from(data['specs'] ?? {}), // 👈 NEW
    );
  }

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0).toDouble(),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      brandName: '',
      specs: Map<String, dynamic>.from(data['specs'] ?? {}), // 👈 NEW
    );
  }
}
