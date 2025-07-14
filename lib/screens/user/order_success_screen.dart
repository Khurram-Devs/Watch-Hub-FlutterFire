import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub_ep/services/pdf_invoice_service.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/footer_widget.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const NavDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Order Placed Successfully!",
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your order ID is:",
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              orderId,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/catalog'),
                                  icon: const Icon(Icons.explore),
                                  label: const Text("Continue Shopping"),
                                ),
                                ElevatedButton.icon(
                                  onPressed:
                                      () => context.go('/profile/orders'),
                                  icon: const Icon(Icons.receipt_long),
                                  label: const Text("View Order History"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      await PDFInvoiceService.generateAndDownloadInvoice(
                                        orderId,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Invoice downloaded or shared',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print(e);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error downloading invoice: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download Invoice'),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}
