import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProfileService {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final usersProfile = FirebaseFirestore.instance.collection('usersProfile');

  // ----- Profile -----
  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() =>
      usersProfile.doc(uid).snapshots();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() =>
      usersProfile.doc(uid).get();

  Future<void> updateProfile(Map<String, dynamic> data) =>
      usersProfile.doc(uid).update(data);

  // ----- Addresses -----
  CollectionReference<Map<String, dynamic>> get addressRef =>
      usersProfile.doc(uid).collection('addresses');

  Stream<QuerySnapshot<Map<String, dynamic>>> addressesStream() =>
      addressRef.snapshots();

  Future<void> addAddress(Map<String, dynamic> addr) => addressRef.add(addr);

  Future<void> removeAddress(String id) => addressRef.doc(id).delete();

  // ----- Wishlist (now using array in main doc) -----
  Future<void> addToWishlist(DocumentReference productRef) async {
    await usersProfile.doc(uid).update({
      'wishlist': FieldValue.arrayUnion([productRef])
    });
  }

  Future<void> removeFromWishlist(String productId) async {
    final productRef =
        FirebaseFirestore.instance.collection('products').doc(productId);

    await usersProfile.doc(uid).update({
      'wishlist': FieldValue.arrayRemove([productRef])
    });
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

  // ----- Orders -----
  CollectionReference<Map<String, dynamic>> get ordersRef =>
      usersProfile.doc(uid).collection('orders');

  Stream<QuerySnapshot<Map<String, dynamic>>> ordersStream() =>
      ordersRef.orderBy('createdAt', descending: true).snapshots();

  Future<void> cancelOrder(String orderId) =>
      ordersRef.doc(orderId).update({'status': 'Cancelled'});
}
