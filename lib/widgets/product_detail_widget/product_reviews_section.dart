import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProductReviewsSection extends StatefulWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _showAddReviewDialog() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add a review.")),
      );
      return;
    }

    final TextEditingController reviewController = TextEditingController();
    double rating = 3;

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Add Review"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: reviewController,
                        decoration: const InputDecoration(
                          labelText: "Your Review",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Rating:"),
                          Expanded(
                            child: Slider(
                              value: rating,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: rating.toString(),
                              onChanged: (val) => setState(() => rating = val),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final reviewText = reviewController.text.trim();
                        if (reviewText.isEmpty) return;

                        final productRef = FirebaseFirestore.instance
                            .collection('products')
                            .doc(widget.productId);

                        final reviewRef =
                            productRef.collection('reviews').doc();

                        await reviewRef.set({
                          'userRef': FirebaseFirestore.instance
                              .collection('usersProfile')
                              .doc(user.uid),
                          'review': reviewText,
                          'rating': rating,
                          'createdAt': Timestamp.now(),
                        });

                        Navigator.pop(context);
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId);

    return StreamBuilder<QuerySnapshot>(
      stream: productRef.collection('reviews').snapshots(),
      builder: (context, reviewSnapshot) {
        if (!reviewSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviewDocs = reviewSnapshot.data!.docs;
        final reviewCount = reviewDocs.length;

        double avgRating = 0;
        if (reviewCount > 0) {
          double total = 0;
          for (var doc in reviewDocs) {
            total += (doc['rating'] ?? 0).toDouble();
          }
          avgRating = total / reviewCount;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text("Customer Reviews"),
              subtitle: Text(
                "${avgRating.toStringAsFixed(1)} ★ ($reviewCount review${reviewCount == 1 ? '' : 's'})",
              ),
              trailing:
                  _auth.currentUser != null
                      ? TextButton.icon(
                        onPressed: _showAddReviewDialog,
                        icon: const Icon(Icons.add_comment),
                        label: const Text("Write a Review"),
                      )
                      : null,
            ),
            const Divider(),
            reviewCount == 0
                ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("No reviews yet."),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewDocs.length,
                  itemBuilder: (context, index) {
                    final reviewData =
                        reviewDocs[index].data() as Map<String, dynamic>;
                    final userRef = reviewData['userRef'] as DocumentReference?;
                    final Timestamp createdAt = reviewData['createdAt'];
                    final DateTime createdTime = createdAt.toDate();
                    final String timeAgo = timeago.format(createdTime);

                    if (userRef == null) {
                      return const ListTile(
                        title: Text("Invalid review (missing user)"),
                      );
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: userRef.get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(title: Text("Loading user..."));
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;

                        final fullName =
                            userData?['fullName'] ??
                            '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'
                                .trim();
                        final avatarUrl = userData?['avatarUrl'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : null,
                            child:
                                avatarUrl == null
                                    ? Text(
                                      fullName.isNotEmpty
                                          ? fullName[0].toUpperCase()
                                          : '?',
                                    )
                                    : null,
                          ),
                          title: Text(
                            fullName.isNotEmpty ? fullName : 'Unnamed User',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reviewData['review'] ?? ''),
                              Text(
                                timeAgo,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text("${reviewData['rating']} ★"),
                        );
                      },
                    );
                  },
                ),
          ],
        );
      },
    );
  }
}
