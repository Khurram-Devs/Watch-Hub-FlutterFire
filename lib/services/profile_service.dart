import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProfileService {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final usersProfile = FirebaseFirestore.instance.collection('usersProfile');

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() =>
      usersProfile.doc(uid).snapshots();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() =>
      usersProfile.doc(uid).get();

  Future<void> updateProfile(Map<String, dynamic> data) =>
      usersProfile.doc(uid).update(data);

  CollectionReference<Map<String, dynamic>> get addressRef =>
      usersProfile.doc(uid).collection('addresses');

  Stream<QuerySnapshot<Map<String, dynamic>>> addressesStream() =>
      addressRef.snapshots();

  Future<void> addAddress(Map<String, dynamic> addr) => addressRef.add(addr);

  Future<void> removeAddress(String id) => addressRef.doc(id).delete();

  CollectionReference<Map<String, dynamic>> get wishlistRef =>
      usersProfile.doc(uid).collection('wishlist');

  Stream<QuerySnapshot<Map<String, dynamic>>> wishlistStream() =>
      wishlistRef.snapshots();

  Future<void> removeFromWishlist(String docId) =>
      wishlistRef.doc(docId).delete();

  Future<void> addToWishlist(DocumentReference productRef) =>
      wishlistRef.add({'product': productRef});

  CollectionReference<Map<String, dynamic>> get ordersRef =>
      usersProfile.doc(uid).collection('orders');

  Stream<QuerySnapshot<Map<String, dynamic>>> ordersStream() =>
      ordersRef.orderBy('createdAt', descending: true).snapshots();

  Future<void> cancelOrder(String orderId) =>
      ordersRef.doc(orderId).update({'status': 'Cancelled'});

  Future<void> moveToCart(ProductModel product) async {
    debugPrint('Moving to cart: ${product.title}');
  }

  Future<List<ProductModel>> getProductsFromRefs(List<dynamic> refs) async {
    final List<ProductModel> products = [];

    for (var ref in refs) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        if (doc.exists) {
          final product = await ProductModel.fromFirestoreWithBrand(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          products.add(product);
        }
      }
    }

    return products;
  }
}
