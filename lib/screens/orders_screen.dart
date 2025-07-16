import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/utils/string_utils.dart';
import 'package:watch_hub_ep/widgets/orders_screen_widget/order_detail_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watch_hub_ep/widgets/skeleton_widget/orders_skeleton.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ProfileService _srv = ProfileService();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Orders',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Order ID...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _srv.ordersStream(),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return OrdersSkeleton(isWide: isWide);
                        }

                        final docs = snap.data?.docs;
                        if (docs == null || docs.isEmpty) {
                          return const Center(child: Text('No orders found.'));
                        }

                        final filteredDocs =
                            docs.where((doc) {
                              return doc.id.toLowerCase().contains(_searchText);
                            }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(
                            child: Text('No matching orders.'),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 2 : 1,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: isWide ? 2.5 : 1.6,
                              ),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, i) {
                            final doc = filteredDocs[i];
                            final data = doc.data();
                            final status = data['status'] ?? 'Unknown';
                            final createdAt =
                                (data['createdAt'] as Timestamp).toDate();
                            final items =
                                (data['items'] as List<dynamic>? ?? [])
                                    .cast<Map<String, dynamic>>();
                            final total =
                                (data['total'] as num?)?.toDouble() ?? 0.0;

                            return GestureDetector(
                              onTap:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (_) => OrderDetailModal(
                                          orderId: doc.id,
                                          orderData: data,
                                        ),
                                  ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order #${doc.id}',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(createdAt),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey.shade600,
                                                  ),
                                            ),
                                            const Divider(height: 24),
                                            ...items
                                                .take(2)
                                                .map(
                                                  (item) => _buildItemRow(item),
                                                ),
                                            if (items.length > 2)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Text(
                                                  '+ ${items.length - 2} more...',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            theme
                                                                .colorScheme
                                                                .primary,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          (status == 'pending' ||
                                                  status.toLowerCase() ==
                                                      'cancelled')
                                              ? MainAxisAlignment.spaceBetween
                                              : MainAxisAlignment.center,
                                      children: [
                                        Chip(
                                          label: Text(
                                            capitalize(status),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: _getStatusColor(
                                            status,
                                          ),
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                        ),

                                        if (status == 'pending')
                                          TextButton.icon(
                                            onPressed: () async {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (_) => AlertDialog(
                                                      title: Text(
                                                        'Cancel Order',
                                                        style: TextStyle(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      content: const Text(
                                                        'Do you really want to cancel this order?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'No',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'Yes',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm == true) {
                                                await _srv.cancelOrder(doc.id);
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                              size: 18,
                                            ),
                                            label: const Text('Cancel'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.redAccent,
                                            ),
                                          ),

                                        if (status.toLowerCase() == 'cancelled')
                                          TextButton.icon(
                                            onPressed: () async {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (_) => AlertDialog(
                                                      title: Text(
                                                        'Remove Order',
                                                        style: TextStyle(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      content: const Text(
                                                        'Do you want to permanently delete this cancelled order?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'No',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'Yes, Delete',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirm == true) {
                                                final uid =
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                          'usersProfile',
                                                        )
                                                        .doc()
                                                        .id; // WRONG WAY

                                                final currentUser =
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser;
                                                if (currentUser == null) return;

                                                await FirebaseFirestore.instance
                                                    .collection('usersProfile')
                                                    .doc(currentUser.uid)
                                                    .collection('orders')
                                                    .doc(doc.id)
                                                    .delete();

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Order removed successfully.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                            ),
                                            label: const Text('Remove'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.redAccent,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (status == 'Shipped')
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Tracking not implemented yet.',
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.local_shipping_outlined,
                                        ),
                                        label: const Text('Track'),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return Colors.redAccent;
      case 'shipped':
        return Colors.green;
      case 'delivered':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}

final Map<String, Future<DocumentSnapshot>> _productSnapshotCache = {};

Future<DocumentSnapshot> _getCachedProduct(DocumentReference ref) {
  final key = ref.path;
  return _productSnapshotCache.putIfAbsent(key, () => ref.get());
}

Widget _buildItemRow(Map<String, dynamic> item) {
  final ref = item['productRef'] as DocumentReference;
  final qty = item['quantity'] ?? 1;

  return FutureBuilder<DocumentSnapshot>(
    future: _getCachedProduct(ref),
    builder: (context, snap) {
      if (!snap.hasData) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: const [
              SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: Text('Loading...')),
            ],
          ),
        );
      }

      final product = snap.data!.data() as Map<String, dynamic>?;
      final title = product?['title'] ?? 'Unknown';
      final images = product?['images'] as List<dynamic>? ?? [];
      final imageUrl = images.isNotEmpty ? images.first.toString() : '';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 1),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 20),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('$title × $qty', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    },
  );
}
