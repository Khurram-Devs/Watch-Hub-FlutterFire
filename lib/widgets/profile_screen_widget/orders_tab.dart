import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/widgets/profile_screen_widget/order_detail_modal.dart';

class OrdersTab extends StatelessWidget {
  OrdersTab({super.key});

  final ProfileService _srv = ProfileService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _srv.ordersStream(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs;
        if (docs == null || docs.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final status = data['status'] as String? ?? 'Unknown';
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final items = (data['items'] as List<dynamic>? ?? [])
                .cast<Map<String, dynamic>>();
            final total = (data['total'] as num?)?.toDouble() ?? 0.0;

            return GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => OrderDetailModal(
                  orderId: docs[i].id,
                  orderData: data,
                ),
              ),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 500;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID & Status Row
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${docs[i].id}',
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: status == 'Cancelled'
                                            ? Colors.red
                                            : status == 'Shipped'
                                                ? Colors.green
                                                : Colors.orange,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Order #${docs[i].id}',
                                        style: theme.textTheme.labelLarge,
                                      ),
                                    ),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: status == 'Cancelled'
                                            ? Colors.red
                                            : status == 'Shipped'
                                                ? Colors.green
                                                : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 6),
                          Text(
                            DateFormat.yMMMd().add_jm().format(createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                          const Divider(height: 20),

                          // Order Items Preview
                          ...items.take(2).map((item) {
                            final DocumentReference ref = item['productRef'];
                            final quantity = item['quantity'] ?? 1;

                            return FutureBuilder<DocumentSnapshot>(
                              future: ref.get(),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Text('• Loading product...'),
                                  );
                                }

                                final productData =
                                    snap.data!.data() as Map<String, dynamic>?;
                                final title =
                                    productData?['title'] ?? 'Unknown';

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Text('• $title × $quantity'),
                                );
                              },
                            );
                          }).toList(),

                          if (items.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '+ ${items.length - 2} more...',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),

                          const SizedBox(height: 10),
                          Text(
                            'Total: \$${total.toStringAsFixed(2)}',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 12),

                          // Buttons
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              if (status == 'Pending')
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Cancel Order'),
                                        content: const Text(
                                            'Do you really want to cancel this order?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('No'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _srv.cancelOrder(docs[i].id);
                                    }
                                  },
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancel Order'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                ),

                              if (status == 'Shipped')
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Tracking not implemented yet.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.local_shipping),
                                  label: const Text('Track Order'),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
