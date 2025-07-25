import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About WatchHub",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "At WatchHub, we believe a timepiece is more than a way to tell time — it’s a symbol of craftsmanship, identity, and timeless style. "
                  "As your trusted destination for luxury watches, we bring the finest collections from world-renowned brands directly to your wrist.",
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),

                Divider(color: theme.dividerColor, thickness: 1.2),
                const SizedBox(height: 24),

                Text(
                  "🌟 Why Shop With Us?",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                _buildFeature(
                  icon: Icons.workspace_premium_rounded,
                  title: "Exquisite Collections",
                  description:
                      "From heritage classics to cutting-edge designs, each watch we offer reflects excellence and artistry.",
                ),
                _buildFeature(
                  icon: Icons.verified_user_rounded,
                  title: "100% Authenticity",
                  description:
                      "All timepieces are sourced from authorized distributors and come with verified certificates.",
                ),
                _buildFeature(
                  icon: Icons.local_shipping_rounded,
                  title: "Global Shipping",
                  description:
                      "We deliver worldwide with fast, insured, and reliable logistics to ensure safe arrival of your purchase.",
                ),
                _buildFeature(
                  icon: Icons.headset_mic_rounded,
                  title: "Luxury Support",
                  description:
                      "Our experts are available to guide you, from choosing the right watch to post-purchase care.",
                ),
                _buildFeature(
                  icon: Icons.payment_rounded,
                  title: "Secure Payments",
                  description:
                      "We support trusted, encrypted payment options including cards, wallets, and cash-on-delivery where available.",
                ),

                const SizedBox(height: 32),
                Divider(color: theme.dividerColor, thickness: 1.2),
                const SizedBox(height: 32),

                Text(
                  "⏱️ A Legacy in the Making",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "WatchHub was founded with a singular purpose — to redefine the online watch shopping experience. "
                  "We are committed to offering premium service, curated collections, and a platform built on trust and elegance.",
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "© ${DateTime.now().year} WatchHub. All rights reserved.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: const Color(0xFFC0A265)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
