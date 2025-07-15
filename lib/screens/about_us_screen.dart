import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

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
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "WatchHub is a premium destination for watch enthusiasts, offering a seamless and luxurious shopping experience through a modern Flutter & Firebase-powered mobile app. "
                  "We curate the finest selection of timepieces from top global brands, delivering style, precision, and elegance right to your wrist.",
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),

                Divider(color: theme.dividerColor, thickness: 1.2),
                const SizedBox(height: 24),

                Text(
                  "✨ What Makes Us Different",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeature(
                  icon: Icons.watch,
                  title: "Curated Collections",
                  description:
                      "Explore limited-edition and handpicked collections that blend tradition with innovation.",
                ),
                _buildFeature(
                  icon: Icons.security,
                  title: "Authenticity Guaranteed",
                  description:
                      "Every watch is sourced from verified suppliers and undergoes strict quality checks.",
                ),
                _buildFeature(
                  icon: Icons.flash_on,
                  title: "Fast & Secure Delivery",
                  description:
                      "We ensure your timepiece reaches you quickly and securely, anywhere in the world.",
                ),
                _buildFeature(
                  icon: Icons.support_agent,
                  title: "Dedicated Support",
                  description:
                      "Our team is always available to assist you with personalized recommendations and order support.",
                ),

                const SizedBox(height: 24),
                Divider(color: theme.dividerColor, thickness: 1.2),

                const SizedBox(height: 32),
                Text(
                  "👨‍💻 Built With Passion",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "WatchHub is a student-led Flutter project built with modern UI/UX, real-time cloud integration, and e-commerce best practices.",
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
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
          Icon(icon, size: 32, color: const Color(0xFFC0A265)),
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
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
