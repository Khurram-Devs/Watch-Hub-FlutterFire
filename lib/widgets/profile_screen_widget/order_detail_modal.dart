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
    final createdAt = (orderData['createdAt'] as Timestamp).toDate();
    final items = (orderData['items'] as List<dynamic>).cast<Map<String, dynamic>>();
    final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;
    final tax = (orderData['tax'] as num?)?.toDouble() ?? 0.0;
    final subtotal = (orderData['subtotal'] as num?)?.toDouble() ?? 0.0;
    final shipping = (orderData['shipping'] as num?)?.toDouble() ?? 0.0;
    final discount = (orderData['discount'] as num?)?.toDouble() ?? 0.0;
    final status = orderData['status'] ?? 'Unknown';

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #$orderId', style: theme.textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: () async {
                      await PDFInvoiceService.generateAndDownloadInvoice(orderId);
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download Invoice'),
                  ),
                ],
              ),
              Text(DateFormat.yMMMd().add_jm().format(createdAt), style: theme.textTheme.bodySmall),
              Text('Status: $status', style: theme.textTheme.bodyMedium?.copyWith(color: status == 'Cancelled' ? Colors.red : status == 'Shipped' ? Colors.green : Colors.orange)),
              const Divider(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final qty = item['quantity'] ?? 1;
                    final ref = item['productRef'] as DocumentReference;

                    return FutureBuilder<DocumentSnapshot>(
                      future: ref.get(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator());

                        final product = snap.data!.data() as Map<String, dynamic>? ?? {};
                        final title = product['title'] ?? 'Unknown';
                        final price = (product['price'] as num?)?.toDouble() ?? 0.0;
                        final image = (product['images'] as List?)?.first ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.watch),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: theme.textTheme.titleSmall),
                                    const SizedBox(height: 4),
                                    Text('Quantity: $qty'),
                                    Text('Price: \$${price.toStringAsFixed(2)}'),
                                    Text('Total: \$${(price * qty).toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                    Text('Tax: \$${tax.toStringAsFixed(2)}'),
                    Text('Shipping: \$${shipping.toStringAsFixed(2)}'),
                    Text('Discount: -\$${discount.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
