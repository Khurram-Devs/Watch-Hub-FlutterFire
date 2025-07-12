import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> getSavedAddresses() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot =
        await _firestore
            .collection('usersProfile')
            .doc(uid)
            .collection('addresses')
            .get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

  static Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    final promoSnapshot =
        await _firestore
            .collection('promoCodes')
            .where('code', isEqualTo: code.trim())
            .limit(1)
            .get();

    if (promoSnapshot.docs.isEmpty) return null;

    final data = promoSnapshot.docs.first.data();
    final used = int.tryParse(data['usedTimes'].toString()) ?? 0;
    final limit = int.tryParse(data['limit'].toString()) ?? 0;

    if (used >= limit) return null;

    return {'id': promoSnapshot.docs.first.id, ...data};
  }

static Future<String> placeOrder({
  required List<Map<String, dynamic>> cartItems,
  required double subtotal,
  required double tax,
  required double shipping,
  required double discount,
  required double total,
  String promoCode = '',
  String promoTitle = '',
}) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) throw Exception("User not logged in");

  final orderRef = _firestore
      .collection('usersProfile')
      .doc(uid)
      .collection('orders')
      .doc();

  final List<Map<String, dynamic>> firestoreItems = [];
  final List<Future<void>> inventoryUpdates = [];

  for (final item in cartItems) {
    final product = item['product'];
    final quantity = item['quantity'] ?? 1;
    final productRef = product.firestoreSnapshot?.reference;

    if (productRef != null) {
      firestoreItems.add({
        'productRef': productRef,
        'quantity': quantity,
      });

      inventoryUpdates.add(productRef.update({
        'inventoryCount': FieldValue.increment(-quantity),
      }));
    }
  }

  final orderData = {
    'items': firestoreItems,
    'subtotal': subtotal,
    'tax': tax,
    'shipping': shipping,
    'discount': discount,
    'total': total,
    'promoCode': promoCode,
    'promoTitle': promoTitle,
    'status': 'pending',
    'createdAt': Timestamp.now(),
  };

  await orderRef.set(orderData);
  await Future.wait(inventoryUpdates);
  await clearCart();

  return orderRef.id;
}




  static Future<void> incrementPromoUsage(String promoId) async {
    final promoRef = _firestore.collection('promoCodes').doc(promoId);
    await promoRef.update({'usedTimes': FieldValue.increment(1)});
  }

static Future<void> clearCart() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  final cartRef = _firestore
      .collection('usersProfile')
      .doc(uid)
      .collection('cart');

  final cartSnapshot = await cartRef.get();
  for (final doc in cartSnapshot.docs) {
    await doc.reference.delete();
  }
}
}
