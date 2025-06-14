import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'remove_faq_widget.dart';
import 'edit_faq_widget.dart';

class FAQWidget extends StatelessWidget {
  const FAQWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection('FAQ').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading FAQs"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No FAQs found"));
        }

        final faqs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: faqs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final faqDoc = faqs[index];
            final faq = faqDoc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faq['question'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            faq['answer'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (2 + 2 == 4) ...[
                      EditFAQButton(
                        documentId: faqDoc.id,
                        currentQuestion: faq['question'] ?? '',
                        currentAnswer: faq['answer'] ?? '',
                      ),
                      RemoveFAQButton(documentId: faqDoc.id),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
