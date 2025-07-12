import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:watch_hub_ep/services/checkout_service.dart';

class PromoAndSummarySection extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;

  const PromoAndSummarySection({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
  });

  @override
  State<PromoAndSummarySection> createState() => _PromoAndSummarySectionState();
}

class _PromoAndSummarySectionState extends State<PromoAndSummarySection> {
  final _promoCtrl = TextEditingController();
  Map<String, dynamic>? promo;
  bool isPlacing = false;
  String message = '';

  double get discount =>
      promo == null ? 0.0 : widget.subtotal * (promo!['discountPercent'] / 100);
  double get finalTotal => widget.total - discount;

  Future<void> applyPromo() async {
    final result = await CheckoutService.validatePromoCode(
      _promoCtrl.text.trim(),
    );
    setState(() {
      promo = result;
      message =
          promo != null
              ? 'Promo "${promo!['title']}" applied!'
              : 'Invalid or expired promo code';
    });
  }

  Future<void> placeOrder() async {
  setState(() {
    isPlacing = true;
    message = '';
  });

  try {
    final orderId = await CheckoutService.placeOrder(
      cartItems: widget.cartItems,
      subtotal: widget.subtotal,
      tax: widget.tax,
      shipping: widget.shipping,
      discount: discount,
      total: finalTotal,
      promoCode: promo?['code'] ?? '',
      promoTitle: promo?['title'] ?? '',
    );

    if (promo != null) {
      await CheckoutService.incrementPromoUsage(promo!['id']);
    }

    // Navigate to order success screen with orderId
    if (mounted) context.go('/order-success/$orderId');
  } catch (e) {
    setState(() {
      message = 'Failed to place order: $e';
    });
  } finally {
    if (mounted) setState(() => isPlacing = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promo Code', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoCtrl,
                decoration: const InputDecoration(hintText: 'Enter code'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: applyPromo, child: const Text('Apply')),
          ],
        ),
        if (message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message,
              style: TextStyle(
                color: message.contains('success') ? Colors.green : Colors.red,
              ),
            ),
          ),
        const Divider(height: 32),
        _row('Subtotal', fmt.format(widget.subtotal)),
        _row('Tax (15%)', fmt.format(widget.tax)),
        _row('Shipping', fmt.format(widget.shipping)),
        if (promo != null)
          _row(
            'Promo : ${promo!['title']}  -${promo!['discountPercent']}%',
            '-${fmt.format(discount)}',
          ),
        const Divider(),
        _row('Total', fmt.format(finalTotal), bold: true),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: isPlacing ? null : placeOrder,
          icon: const Icon(Icons.check_circle),
          label:
              isPlacing
                  ? const CircularProgressIndicator()
                  : const Text('Place Order'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
        Text(
          value,
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }
}
