import 'package:flutter/material.dart';
import 'package:watch_hub_ep/widgets/checkout_screen_widget/checkout_form_section.dart';
import 'package:watch_hub_ep/widgets/checkout_screen_widget/promo_and_summary_section.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final formKey = GlobalKey<FormState>(); // <-- Add this

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              isMobile
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutFormSection(
                        isMobile: isMobile,
                        formKey: formKey, // <-- Pass here
                      ),
                      const SizedBox(height: 24),
                      PromoAndSummarySection(
                        formKey: formKey, // <-- Pass here
                        cartItems: cartItems,
                        subtotal: subtotal,
                        tax: tax,
                        shipping: shipping,
                        total: total,
                      ),
                    ],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CheckoutFormSection(
                          isMobile: isMobile,
                          formKey: formKey,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: PromoAndSummarySection(
                          formKey: formKey,
                          cartItems: cartItems,
                          subtotal: subtotal,
                          tax: tax,
                          shipping: shipping,
                          total: total,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
