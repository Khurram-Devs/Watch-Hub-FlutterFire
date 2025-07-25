import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFAQ extends StatelessWidget {
  const ProductFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('productFAQ')
              .orderBy('question')
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Failed to load FAQs."),
          );
        }

        final faqDocs = snapshot.data?.docs ?? [];

        if (faqDocs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No FAQs available."),
          );
        }

        return ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            "Frequently Asked Questions",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          children:
              faqDocs.map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['question'] ?? 'No question'),
                    subtitle: Text(data['answer'] ?? 'No answer provided.'),
                  );
                } catch (e) {
                  debugPrint('Error parsing FAQ doc: $e');
                  return const ListTile(title: Text("Invalid FAQ format."));
                }
              }).toList(),
        );
      },
    );
  }
}
