import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../models/product_model.dart';

class AddToWishlistButton extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const AddToWishlistButton({
    super.key,
    required this.product,
    this.onTap, required String productId,
  });

  @override
  State<AddToWishlistButton> createState() => _AddToWishlistButtonState();
}

class _AddToWishlistButtonState extends State<AddToWishlistButton> {
  bool _isInWishlist = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('usersProfile')
        .doc(user.uid)
        .get();

    final wishlist = (userDoc.data()?['wishlist'] as List?)?.cast<DocumentReference>() ?? [];
    final exists = wishlist.any((ref) => ref.id == widget.product.id);

    setState(() => _isInWishlist = exists);
  }

  Future<void> _toggleWishlist(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add items to wishlist.")),
      );
      context.push('/auth/login');
      return;
    }

    setState(() => _loading = true);

    final docRef = FirebaseFirestore.instance.collection('usersProfile').doc(user.uid);
    final prodRef = FirebaseFirestore.instance.collection('products').doc(widget.product.id);
    final doc = await docRef.get();
    final List wishlist = (doc.data()?['wishlist'] as List?) ?? [];

    if (_isInWishlist) {
      wishlist.removeWhere((ref) => (ref as DocumentReference).id == widget.product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.title} removed from wishlist')),
      );
    } else {
      wishlist.add(prodRef);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.title} added to wishlist')),
      );
    }

    await docRef.update({'wishlist': wishlist});
    setState(() {
      _isInWishlist = !_isInWishlist;
      _loading = false;
    });

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: _loading ? null : () => _toggleWishlist(context),
      icon: Icon(
        _isInWishlist ? Icons.favorite : Icons.favorite_border,
        color: _isInWishlist ? Colors.red : theme.colorScheme.secondary,
      ),
    );
  }
}
