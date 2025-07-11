import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class CartService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference get _cartCollection =>
      _firestore.collection('usersProfile').doc(uid).collection('cart');

Future<List<ProductModel>> fetchCartItems() async {
  if (uid == null) return [];

  final cartDocs = await _cartCollection.get();
  final List<ProductModel> products = [];

  for (var doc in cartDocs.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final productRef = data['productRef'] as DocumentReference;
    final productSnap = await productRef.get();

    if (!productSnap.exists) {
      await doc.reference.delete();
      continue;
    }

    final productData = productSnap.data() as Map<String, dynamic>;
    final product = await ProductModel.fromFirestoreWithBrand(
      productData,
      productSnap.id,
    );
    product.firestoreSnapshot = productSnap;

    if (product.stock != null && product.stock! > 0) {
      products.add(product);
    } else {
      await doc.reference.delete();
    }
  }

  return products;
}


  Future<void> addToCart(ProductModel product) async {
    if (uid == null) return;

    final cartDoc = _cartCollection.doc(product.id);
    final docSnap = await cartDoc.get();

    if (docSnap.exists) {
      // Already in cart → Optionally increase quantity
      await cartDoc.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartDoc.set({
        'productRef': FirebaseFirestore.instance
            .collection('products')
            .doc(product.id),
        'quantity': 1,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateQuantity(String productId, int newQty) async {
    if (uid == null) return;
    await _cartCollection.doc(productId).update({'quantity': newQty});
  }

  Future<void> removeFromCart(String productId) async {
    if (uid == null) return;
    await _cartCollection.doc(productId).delete();
  }

  Future<bool> isInCart(String productId) async {
    if (uid == null) return false;
    final doc = await _cartCollection.doc(productId).get();
    return doc.exists;
  }

Future<List<Map<String, dynamic>>> fetchCartItemsWithQuantity() async {
  if (uid == null) return [];

  final cartDocs = await _cartCollection.get();
  final List<Map<String, dynamic>> result = [];

  for (var doc in cartDocs.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final productRef = data['productRef'] as DocumentReference;
    final quantity = (data['quantity'] ?? 1) as int;

    final productSnap = await productRef.get();

    if (!productSnap.exists) {
      await doc.reference.delete(); 
      continue;
    }

    final productData = productSnap.data() as Map<String, dynamic>;
    final product = await ProductModel.fromFirestoreWithBrand(
      productData,
      productSnap.id,
    );
    product.firestoreSnapshot = productSnap;

    if (product.stock != null && product.stock! > 0) {
      result.add({'product': product, 'quantity': quantity});
    } else {
      await doc.reference.delete(); 
    }
  }

  return result;
}

}
