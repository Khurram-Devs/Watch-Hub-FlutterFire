import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        color: theme.cardColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
      
            final aboutUs = _buildAboutUsSection(context);
            final quickLinks = _buildQuickLinksSection(context);
            final contact = _buildContactSection(context);
      
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: aboutUs),
                          const SizedBox(width: 48),
                          Expanded(child: quickLinks),
                          const SizedBox(width: 48),
                          Expanded(child: contact),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          aboutUs,
                          const SizedBox(height: 24),
                          quickLinks,
                          const SizedBox(height: 24),
                          contact,
                        ],
                      ),
                const SizedBox(height: 32),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '© ${DateTime.now().year} Watch Hub. All rights reserved.',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAboutUsSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About Us", style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          "We build beautiful digital experiences for people around the world. Let’s make something special together.",
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickLinksSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final linkStyle = textTheme.bodySmall?.copyWith(
      decoration: TextDecoration.underline,
      color: theme.colorScheme.secondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Links", style: textTheme.titleMedium),
        const SizedBox(height: 12),
        TextButton(onPressed: () {}, child: Text("Home", style: linkStyle)),
        TextButton(onPressed: () {}, child: Text("Services", style: linkStyle)),
        TextButton(onPressed: () {}, child: Text("Contact", style: linkStyle)),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Contact", style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Text("Email: contact@watchhub.com", style: textTheme.bodySmall),
        Text("Phone: +92 300 0000000", style: textTheme.bodySmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.facebook),
              tooltip: 'Facebook',
              color: theme.colorScheme.secondary,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.link),
              tooltip: 'Website',
              color: theme.colorScheme.secondary,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.email),
              tooltip: 'Email',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
}
