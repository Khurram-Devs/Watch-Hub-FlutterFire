import 'package:flutter/material.dart';
import 'package:watch_hub_ep/widgets/checkout_screen_widget/checkout_form_section.dart';
import 'package:watch_hub_ep/widgets/checkout_screen_widget/promo_and_summary_section.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: const NavDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppHeader(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckoutFormSection(isMobile: isMobile),
                          const SizedBox(height: 16),
                          PromoAndSummarySection(
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
                          Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: CheckoutFormSection(isMobile: isMobile),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: PromoAndSummarySection(
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
            ],
          ),
        ),
      ),
    );
  }
}
