import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub_ep/models/product_model.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Text("Not logged in");
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usersProfile')
          .doc(uid)
          .collection('cart')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final cartDocs = snapshot.data!.docs;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _buildCartItems(cartDocs),
          builder: (context, productSnapshot) {
            if (!productSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = productSnapshot.data!;
            double subtotal = 0;

            for (final item in items) {
              final product = item['product'] as ProductModel;
              final quantity = item['quantity'] as int;
              final priceAfterDiscount =
                  product.price * (1 - product.discountPercentage / 100);
              subtotal += priceAfterDiscount * quantity;
            }

            const shipping = 25.0;
            const taxRate = 0.15;
            final tax = subtotal * taxRate;
            final total = subtotal + tax + shipping;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Summary",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _summaryRow("Subtotal", subtotal),
                    _summaryRow("Estimated Tax (15%)", tax),
                    _summaryRow("Shipping", shipping),
                    const Divider(height: 24),
                    _summaryRow("Total", total, bold: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement checkout
                        },
                        child: const Text("Proceed to Checkout"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _buildCartItems(
      List<QueryDocumentSnapshot> cartDocs) async {
    final List<Map<String, dynamic>> result = [];

    for (final doc in cartDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final quantity = (data['quantity'] ?? 1) as int;
      final productRef = data['productRef'] as DocumentReference;
      final productSnap = await productRef.get();

      if (productSnap.exists) {
        final productData = productSnap.data() as Map<String, dynamic>;
        final product = await ProductModel.fromFirestoreWithBrand(
            productData, productSnap.id);
        result.add({'product': product, 'quantity': quantity});
      }
    }

    return result;
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
