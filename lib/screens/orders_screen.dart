import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/widgets/orders_screen_widget/order_detail_modal.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final ProfileService _srv = ProfileService();

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
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _srv.ordersStream(),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snap.data?.docs;
                        if (docs == null || docs.isEmpty) {
                          return const Center(child: Text('No orders found.'));
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 2 : 1,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: isWide ? 2.5 : 1.6,
                              ),
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final data = docs[i].data();
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
                                          orderId: docs[i].id,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${docs[i].id}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat.yMMMd().add_jm().format(
                                        createdAt,
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    const Divider(height: 24),

                                    ...items.take(2).map((item) {
                                      final ref =
                                          item['productRef']
                                              as DocumentReference;
                                      final qty = item['quantity'] ?? 1;

                                      return FutureBuilder<DocumentSnapshot>(
                                        future: ref.get(),
                                        builder: (context, snap) {
                                          if (!snap.hasData) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 36,
                                                    height: 36,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Expanded(
                                                    child: Text('Loading...'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          final product =
                                              snap.data!.data()
                                                  as Map<String, dynamic>?;
                                          final title =
                                              product?['title'] ?? 'Unknown';
                                          final imageList =
                                              product?['images']
                                                  as List<dynamic>? ??
                                              [];
                                          final imageUrl =
                                              imageList.isNotEmpty
                                                  ? imageList.first.toString()
                                                  : '';

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          width: 40,
                                                          height: 40,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade200,
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 20,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    '$title × $qty',
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),

                                    if (items.length > 2)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '+ ${items.length - 2} more...',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                        ),
                                      ),

                                    const SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total:',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            Text(
                                              '\$${total.toStringAsFixed(2)}',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Chip(
                                          label: Text(
                                            status,
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
                                            vertical: 2,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Action Buttons
                                    Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 12,
                                      children: [
                                        if (status == 'Pending')
                                          TextButton.icon(
                                            onPressed: () async {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (_) => AlertDialog(
                                                      title: const Text(
                                                        'Cancel Order',
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
                                                await _srv.cancelOrder(
                                                  docs[i].id,
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                            ),
                                            label: const Text('Cancel'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.redAccent,
                                            ),
                                          ),
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
    switch (status) {
      case 'Cancelled':
        return Colors.redAccent;
      case 'Shipped':
        return Colors.green;
      case 'Delivered':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
