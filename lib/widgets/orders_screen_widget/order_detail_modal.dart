import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watch_hub_ep/services/pdf_invoice_service.dart';

class OrderDetailModal extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailModal({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final items = (orderData['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;
    final tax = (orderData['tax'] as num?)?.toDouble() ?? 0.0;
    final subtotal = (orderData['subtotal'] as num?)?.toDouble() ?? 0.0;
    final shipping = (orderData['shipping'] as num?)?.toDouble() ?? 0.0;
    final discount = (orderData['discount'] as num?)?.toDouble() ?? 0.0;
    final status = orderData['status'] ?? 'Unknown';

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 620, maxWidth: 600),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #$orderId', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMMMd().add_jm().format(createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getStatusColor(status),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // INVOICE BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Download Invoice'),
                  onPressed: () async {
                    await PDFInvoiceService.generateAndDownloadInvoice(orderId);
                  },
                ),
              ),
            ),

            const Divider(height: 24),

            // ITEM LIST
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Scrollbar(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final qty = item['quantity'] ?? 1;
                      final ref = item['productRef'] as DocumentReference?;

                      if (ref == null) return const SizedBox();

                      return FutureBuilder<DocumentSnapshot>(
                        future: ref.get(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(child: LinearProgressIndicator());
                          }

                          final product = snap.data!.data() as Map<String, dynamic>? ?? {};
                          final title = product['title'] ?? 'Unknown';
                          final price = (product['price'] as num?)?.toDouble() ?? 0.0;
                          final imageList = product['images'] as List? ?? [];
                          final imageUrl = imageList.isNotEmpty ? imageList.first.toString() : '';

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.watch, size: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Quantity: $qty'),
                                    Text('Price: \$${price.toStringAsFixed(2)}'),
                                    Text(
                                      'Total: \$${(price * qty).toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // FOOTER TOTALS
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _totalRow('Subtotal', subtotal),
                    _totalRow('Tax', tax),
                    _totalRow('Shipping', shipping),
                    _totalRow('Discount', -discount),
                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        '$label: \$${value.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 14),
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
